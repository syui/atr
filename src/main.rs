extern crate rustc_serialize;
pub mod data;
use std::env;
use std::path::Path;
use std::io;
use std::fs;
use std::collections::HashMap;

use serde::{Deserialize, Serialize};
use rustc_serialize::json::Json;

use seahorse::{App, Command, Context, Flag, FlagType};

use smol_str::SmolStr;
use iso8601_timestamp::Timestamp;

use data::Status as Status;
use data::Notify as Notify;
use data::Token as Token;
use data::Cid as Cid;
use data::Profile as Profile;
use data::Handle as Handle;
use data::Deep as Deeps;
use data::Open as Opens;
use crate::data::Timeline;
//use crate::data::Session;
use crate::data::url;
use crate::data::cfg;
use crate::data::token_file;
use crate::data::token_toml;
use crate::data::Tokens;

use std::fs::OpenOptions;
use std::io::Read;
use std::io::Write;

//use std::{thread, time};

pub mod openai;
pub mod openai_char;
pub mod deepl;
pub mod at_refresh;
pub mod at_notify_limit;
pub mod at_notify_read;
pub mod at_reply;
pub mod at_reply_link;
pub mod at_reply_media;
pub mod at_reply_og;
pub mod at_post;
pub mod at_post_link;
pub mod at_profile;
pub mod at_mention;
pub mod at_timeline;
pub mod at_timeline_author;
pub mod at_handle_update;
pub mod at_like;
pub mod at_repost;
pub mod at_follow;
pub mod at_follows;
pub mod at_followers;
pub mod at_user_status;
pub mod at_img;
pub mod at_img_reply;

// timestamp
#[derive(Debug, Clone, Serialize)]
pub struct Event {
    pub name: SmolStr,
    pub ts: Timestamp,
    pub value: i32,
}

#[derive(Serialize)]
struct Setting {
    host: String,
    user: String,
    pass: String,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type")]
struct DeepData {
    translations: Vec<Translation>,
}

#[derive(Serialize, Deserialize, Debug)]
struct Translation {
    text: String,
    detected_source_language : String,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type")]
struct OpenData {
    choices: Vec<Choices>,
}

#[derive(Serialize, Deserialize, Debug)]
struct Choices {
    text: String,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type")]
struct OpenChar {
    choices: Vec<ChoicesChar>,
}

#[derive(Serialize, Deserialize, Debug)]
struct ChoicesChar {
    message: OpenContent,
}

#[derive(Serialize, Deserialize, Debug)]
struct OpenContent {
    content: String,
}

fn main() {
    let args: Vec<String> = env::args().collect(); let app = App::new(env!("CARGO_PKG_NAME"))
        .author(env!("CARGO_PKG_AUTHORS"))
        .description(env!("CARGO_PKG_DESCRIPTION"))
        .version(env!("CARGO_PKG_VERSION"))
        .usage("atr [option] [x]\n\t~/.config/atr/config.toml\n\t\thost = 'bsky.social'\n\t\tuser = 'syui.bsky.social'\n\t\tpass = 'xxx'")
        .command(
            Command::new("start")
            .usage("atr start")
            .description("start first\n\t\t\t$ atr start\n\t\t\t$ atr start -u $user.bsky.social -p $password")
            .action(first)
            .flag(
                Flag::new("pass", FlagType::String)
                .description("pass")
                .alias("p"),
                )
            .flag(
                Flag::new("host", FlagType::String)
                .description("host")
                .alias("h"),
                )
            .flag(
                Flag::new("user", FlagType::String)
                .description("user")
                .alias("u"),
                )
            )
        .command(
            Command::new("auth")
            .usage("atr a")
            .description("auth\n\t\t\t$ atr a\n\t\t\t$ cat ~/.config/atr/token.json")
            .alias("a")
            .action(a),
            )
        .command(
            Command::new("token")
            .usage("atr token")
            .description("token\n\t\t\t$ atr refresh")
            .action(a_token),
            )
        .command(
            Command::new("refresh")
            .usage("atr refresh")
            .description("refresh\n\t\t\t$ atr refresh")
            .action(refresh),
            )
        .command(
            Command::new("swich")
            .usage("msr swich {}")
            .description("account switch\n\t\t\t$ atr ss -d(setting.toml)\n\t\t\t$ atr ss -s(social.toml)")
            .alias("ss")
            .action(account_switch),
            )
        .command(
            Command::new("create")
            .usage("atr create")
            .description("create account\n\t\t\t$ atr c -i $invite_code -e $email")
            .alias("c")
            .action(c)
            .flag(
                Flag::new("invite", FlagType::String)
                .description("invite flag")
                .alias("i"),
                )
            .flag(
                Flag::new("email", FlagType::String)
                .description("email flag")
                .alias("e"),
                )
            )
        .command(
            Command::new("status")
            .usage("atr s")
            .description("status user\n\t\t\t$ atr s\n\t\t\t$ atr s -u user.bsky.social")
            .alias("s")
            .action(s)
            .flag(
                Flag::new("user", FlagType::String)
                .description("user flag(ex: $ atr s -u user)")
                .alias("u"),
                )
            .flag(
                Flag::new("profile", FlagType::String)
                .description("user flag(ex: $ atr s -p user)")
                .alias("p"),
                )
            .flag(
                Flag::new("did", FlagType::Bool)
                .description("did flag(ex: $ atr s -d handle)")
                .alias("d"),
                )
            )
        .command(
            Command::new("did")
            .usage("atr did handle")
            .description("search handle did\n\t\t\t$ atr like\n\t\t\t$ atr like subject")
            .action(did)
            )
        .command(
            Command::new("like")
            .usage("atr like")
            .description("like post\n\t\t\t$ atr like\n\t\t\t$ atr like subject")
            .action(like)
            .flag(
                Flag::new("uri", FlagType::String)
                .description("uri(ex: $ atr like <cid> -u <uri>)")
                .alias("u"),
                )
            )
        .command(
            Command::new("repost")
            .usage("atr repost")
            .description("repost\n\t\t\t$ atr repost\n\t\t\t$ atr repost subject")
            .action(repost)
            .flag(
                Flag::new("uri", FlagType::String)
                .description("uri(ex: $ atr repost <cid> -u <uri>)")
                .alias("u"),
                )
            )
        .command(
            Command::new("reply-og")
            .usage("atr repost")
            .description("repost\n\t\t\t$ atr repost\n\t\t\t$ atr repost subject")
            .action(reply_og)
            .flag(
                Flag::new("uri", FlagType::String)
                .description("uri(ex: $ atr repost <cid> -u <uri>)")
                )
            .flag(
                Flag::new("cid", FlagType::String)
                .description("uri(ex: $ atr repost <cid> -u <uri>)")
                )
            .flag(
                Flag::new("link", FlagType::String)
                .description("uri(ex: $ atr repost <cid> -u <uri>)")
                )
            .flag(
                Flag::new("title", FlagType::String)
                .description("uri(ex: $ atr repost <cid> -u <uri>)")
                )
            .flag(
                Flag::new("description", FlagType::String)
                .description("uri(ex: $ atr repost <cid> -u <uri>)")
                )
            .flag(
                Flag::new("img", FlagType::String)
                .description("uri(ex: $ atr repost <cid> -u <uri>)")
                )
            )
            .command(
                Command::new("handle")
            .usage("atr h")
            .description("handle update\n\t\t\t$ atr -h example.com\n\t\t\t$ atr -h user.bsky.social")
            .alias("h")
            .action(h)
            )
        .command(
            Command::new("feed")
            .usage("atr f")
            .description("feed user\n\t\t\t$ atr f\n\t\t\t$ atr f -u user.bsky.social")
            .alias("f")
            .action(f)
            .flag(
                Flag::new("user", FlagType::String)
                .description("user flag(ex: $ atr f -u user)")
                .alias("u"),
                )
            )
        .command(
            Command::new("post")
            .usage("atr p {}")
            .description("post\n\t\t\t$ atr p $text\n\t\t\t$ atr p $text -l https://syui.cf")
            .alias("p")
            .action(p)
            .flag(
                Flag::new("link", FlagType::String)
                .description("link flag(ex: $ atr p -l)")
                .alias("l"),
                )
            .flag(
                Flag::new("cid", FlagType::String)
                .description("link flag(ex: $ atr p -l)")
                )
            .flag(
                Flag::new("uri", FlagType::String)
                .description("link flag(ex: $ atr p -l)")
                )
            .flag(
                Flag::new("en", FlagType::Bool)
                .description("english flag(ex: $ atr p $text -e)")
                .alias("e"),
                )
            .flag(
                Flag::new("ja", FlagType::Bool)
                .description("japanese flag(ex: $ atr p $text -j)")
                .alias("j"),
                )
            .flag(
                Flag::new("chat", FlagType::Bool)
                .description("chatgpt flag(ex: $ atr p $text -j)")
                .alias("c"),
                )
            .flag(
                Flag::new("chat-ja", FlagType::Bool)
                .description("chatgpt japanese mode flag(ex: $ atr p $text -j)")
                )
            )
            .command(
                Command::new("reply")
                .usage("atr r {}")
                .description("reply\n\t\t\t$ atr r $text -u $uri -c $cid")
                .alias("r")
                .action(r)
                .flag(
                    Flag::new("uri", FlagType::String)
                    .description("uri flag(ex: $ atr r -u)")
                    .alias("u"),
                    )
                .flag(
                    Flag::new("cid", FlagType::String)
                    .description("cid flag(ex: $ atr r -u -c)")
                    .alias("c"),
                    )
                .flag(
                    Flag::new("link", FlagType::String)
                    .description("link flag(ex: $ atr r $text -u $uri -c $cid -l $link)")
                    .alias("l"),
                    )
                )
            .command(
                Command::new("mention")
                .usage("atr mention {}")
                .description("mention\n\t\t\t$ atr @ syui.bsky.social -p $text")
                .alias("@")
                .action(mention_run)
                .flag(
                    Flag::new("post", FlagType::String)
                    .description("post flag\n\t\t\t$ atr @ syui.bsky.social -p text")
                    .alias("p"),
                    )
                )
            .command(
                Command::new("timeline")
                .usage("atr t")
                .description("timeline\n\t\t\t$ atr t")
                .alias("t")
                .action(t)
                .flag(
                    Flag::new("json", FlagType::Bool)
                    .description("count flag\n\t\t\t$ atr t -j")
                    .alias("j"),
                    )
                .flag(
                    Flag::new("latest", FlagType::Bool)
                    .description("count flag\n\t\t\t$ atr t -l")
                    .alias("l"),
                    )
                )
            .command(
                Command::new("follow")
                .usage("atr follow")
                .description("follow\n\t\t\t$ atr follow did")
                .action(follow)
                .flag(
                    Flag::new("follows", FlagType::Bool)
                    .description("follows\n\t\t\t$ atr follow -s")
                    .alias("s"),
                    )
                .flag(
                    Flag::new("delete", FlagType::String)
                    .description("delete follow\n\t\t\t$ atr follow -d rkey")
                    .alias("d"),
                    )
                .flag(
                    Flag::new("followers", FlagType::Bool)
                    .description("followers\n\t\t\t$ atr follow -w")
                    .alias("w"),
                    )
                .flag(
                    Flag::new("all", FlagType::Bool)
                    .description("followback and unfollow\n\t\t\t$ atr follow -a")
                    .alias("a"),
                    )
                .flag(
                    Flag::new("cursor", FlagType::String)
                    .description("cursor flag\n\t\t\t$ atr follow -s -c xxx:xxx")
                    .alias("c"),
                    )
                )
            .command(
                Command::new("media")
                .usage("atr m {} -p text")
                .description("media post\n\t\t\t$ atr m ~/test.png")
                .alias("m")
                .action(m)
                )
            .command(
                Command::new("notify-all")
                .usage("atr m {} -p text")
                .description("media post\n\t\t\t$ atr m ~/test.png")
                .action(notify_all)
                )
            .command(
                Command::new("img-upload")
                .usage("atr img-upload {} -p text")
                .description("media post\n\t\t\t$ atr img-upload ~/test.png")
                .action(img_upload)
                )
            .command(
                Command::new("img-post")
                .usage("atr img-post text -l link")
                .description("media post\n\t\t\t$ atr img-post text -l link")
                .action(img_post)
                .flag(
                    Flag::new("link", FlagType::String)
                    .description("link flag\n\t\t\t$ atr img-post text -l link")
                    .alias("l"),
                    )
                .flag(
                    Flag::new("uri", FlagType::String)
                    .description("uri flag\n\t\t\t$ atr img-post text -l link")
                    .alias("u"),
                    )
                .flag(
                    Flag::new("cid", FlagType::String)
                    .description("cid flag\n\t\t\t$ atr img-post text -l link")
                    .alias("c"),
                    )
                )
            .command(
                Command::new("profile")
                .usage("atr profile")
                .description("profile\n\t\t\t$ atr pro\n\t\t\t$ atr pro yui.bsky.social")
                .alias("pro")
                .action(profile)
                .flag(
                    Flag::new("post", FlagType::Bool)
                    .description("user flag(ex: $ atr pro syui.bsky.social -p)")
                    .alias("p"),
                    )
                )
            .command(
                Command::new("notify")
                .usage("atr notify {}")
                .description("notify\n\t\t\t$ atr n")
                .alias("n")
                .action(n)
                .flag(
                    Flag::new("latest", FlagType::Bool)
                    .description("latest flag\n\t\t\t$ atr n -l")
                    .alias("l"),
                    )
                .flag(
                    Flag::new("cid", FlagType::Bool)
                    .description("cid write flag\n\t\t\t$ atr n -cid")
                    )
                .flag(
                    Flag::new("json", FlagType::Bool)
                    .description("json flag\n\t\t\t$ atr n -j")
                    .alias("j"),
                    )
                .flag(
                    Flag::new("limit", FlagType::Int)
                    .description("number limit flag\n\t\t\t$ atr n -n")
                    .alias("n"),
                    )
                .flag(
                    Flag::new("check", FlagType::Bool)
                    .description("number limit flag\n\t\t\t$ atr n -c")
                    .alias("c"),
                    )
                .flag(
                    Flag::new("clean", FlagType::Bool)
                    .description("nofity cleanup limit flag\n\t\t\t$ atr n -clean")
                    )
                )
            .command(
                Command::new("deepl")
                .usage("atr tt {}")
                .description("translate deepl\n\t\t\t$ atr tt $text -l en")
                .alias("tt")
                .action(deepl_read)
                .flag(
                    Flag::new("lang", FlagType::String)
                    .description("Lang flag")
                    .alias("l"),
                    )
                )
            .command(
                Command::new("deepl-api")
                .usage("atr deepl-api {}")
                .description("deepl-api\n\t\t\t$ atr deepl-api $deepl_api_key")
                .action(deepl_api),
                )
            .command(
                Command::new("openai")
                .usage("atr chatgpt {}")
                .description("openai-chatgpt\n\t\t\t$ atr chat $text")
                .alias("chat")
                .action(openai_read)
                .flag(
                    Flag::new("model", FlagType::String)
                    .description("model flag")
                    .alias("m"),
                    )
                .flag(
                    Flag::new("char", FlagType::Bool)
                    .description("model flag")
                    .alias("c"),
                    )
                )
            .command(
                Command::new("openai-api")
                .usage("atr openai-api {}")
                .description("openai-api\n\t\t\t$ atr openai-api $openai_api_key")
                .action(openai_api),
                )
            .command(
                Command::new("bot")
                .usage("atr bot {}")
                .description("bot\n\t\t\t$ atr bot")
                .alias("b")
                .action(bot)
                .flag(
                    Flag::new("limit", FlagType::Int)
                    .description("nofity limit")
                    .alias("l"),
                    )
                .flag(
                    Flag::new("admin", FlagType::String)
                    .description("set admin")
                    .alias("a"),
                    )
                .flag(
                    Flag::new("mode", FlagType::Bool)
                    .description("model flag")
                    .alias("m"),
                    )
                )
                .command(
                    Command::new("bot-tl")
                    .usage("atr bot-tl {}")
                    .description("bot\n\t\t\t$ atr bot-tl")
                    .action(bot_timeline)
                    .flag(
                        Flag::new("limit", FlagType::Int)
                        .description("nofity limit")
                        .alias("l"),
                        )
                    .flag(
                        Flag::new("admin", FlagType::String)
                        .description("set admin")
                        .alias("a"),
                        )
                    )
                .command(
                    Command::new("bot-ch")
                    .usage("atr bot-ch {}")
                    .description("bot\n\t\t\t$ atr bot-ch")
                    .action(bot_change)
                    )
                .command(
                    Command::new("test")
                    .usage("atr test{}")
                    .description("test\n\t\t\t$ atr test")
                    .action(test),
                    )
                ;
    app.run(args);
}

#[tokio::main]
async fn at_user(url: String,user :String) -> reqwest::Result<()> {
    let client = reqwest::Client::new();
    let body = client.get(url)
        .query(&[("repo", &user)])
        .send()
        .await?
        .text()
        .await?;
    println!("{}", body);
    Ok(())
}

#[tokio::main]
async fn at_user_did(url: String,user :String) -> reqwest::Result<()> {
    let client = reqwest::Client::new();
    let res = client.get(url)
        .query(&[("repo", &user)])
        .send()
        .await?
        .text()
        .await?;
    let status: Status = serde_json::from_str(&res).unwrap();
    println!("{}", status.did);
    Ok(())
}

#[allow(unused_must_use)]
fn ss(c :&Context) -> reqwest::Result<()> {
    let m = c.args[0].to_string();
    let url = url(&"describe");
    if let Ok(user) = c.string_flag("user") {
        at_user(url, user);
    } else {
        if c.bool_flag("did") {
            at_user_did(url, m);
        } else {
            let handle = cfg(&"user");
            at_user(url, handle);
        }
    }
    Ok(())
}

fn s(c: &Context) {
    ss(c).unwrap();
}

#[allow(unused_must_use)]
fn did_c(c: &Context) -> reqwest::Result<()> {
    let m = c.args[0].to_string();
    let url = url(&"describe");
    at_user_did(url, m);
    Ok(())
}

fn did(c: &Context) {
    did_c(c).unwrap();
}

fn ff(c: &Context) {
    let user = cfg(&"user");
    let h = async {
        if c.args.len() == 0 {
            let str = at_timeline_author::get_request(user.to_string());
            println!("{}",str.await);    
        } else {
            let m = c.args[0].to_string();
            let str = at_timeline_author::get_request(m.to_string());
            println!("{}",str.await);    
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn f(c: &Context) {
    aa().unwrap();
    ff(c);
}

//fn refresh_c() {
//    let h = async {
//        let str = at_refresh::post_request();
//        println!("{}",str.await);
//    };
//    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
//    return res
//}

#[tokio::main]
async fn c_refresh() -> reqwest::Result<()> {
    let host = cfg(&"host");
    let f = token_file(&"json");
    let refresh = token_toml(&"refresh");
    let url = "https://".to_string() + &host.to_string() + &"/xrpc/com.atproto.server.refreshSession".to_string();
    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .header("Authorization", "Bearer ".to_owned() + &refresh)
        .send()
        .await?
        .text()
        .await?;
    let j = Json::from_str(&res).unwrap();
    let j = j.to_string();
    println!("{}", j);
    let mut f = fs::File::create(f).unwrap();
    if j != "" {
        f.write_all(&j.as_bytes()).unwrap();
    }

    let f = token_file(&"toml");
    let json: Token = serde_json::from_str(&res).unwrap();
    let tokens = Tokens {
        did: json.did.to_string(),
        access: json.accessJwt.to_string(),
        refresh: json.refreshJwt.to_string(),
        handle: json.handle.to_string(),
    };

    let toml = toml::to_string(&tokens).unwrap();
    let mut f = fs::File::create(f.clone()).unwrap();
    f.write_all(&toml.as_bytes()).unwrap();

    Ok(())
}

fn refresh(_c: &Context) {
    c_refresh().unwrap();
    //refresh_c();
}

#[tokio::main]
async fn w_refresh() -> reqwest::Result<()> {
    let host = cfg(&"host");
    // refresh token
    let f = token_file(&"json");
    let refresh = token_toml(&"refresh");
    let url = "https://".to_string() + &host.to_string() + &"/xrpc/com.atproto.server.refreshSession".to_string();
    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .header("Authorization", "Bearer ".to_owned() + &refresh)
        .send()
        .await?
        .text()
        .await?;
    let j = Json::from_str(&res).unwrap();
    let j = j.to_string();
    println!("{}", j);
    let mut f = fs::File::create(f).unwrap();
    if j != "" {
        f.write_all(&j.as_bytes()).unwrap();
    }

    let f = token_file(&"toml");
    let json: Token = serde_json::from_str(&res).unwrap();
    let tokens = Tokens {
        did: json.did.to_string(),
        access: json.accessJwt.to_string(),
        refresh: json.refreshJwt.to_string(),
        handle: json.handle.to_string(),
    };
    let toml = toml::to_string(&tokens).unwrap();
    let mut f = fs::File::create(f.clone()).unwrap();
    f.write_all(&toml.as_bytes()).unwrap();
    Ok(())
}

#[tokio::main]
async fn w_token() -> reqwest::Result<()> {
    let host = cfg(&"host");
    // create session
    let url = "https://".to_string() + &host.to_string() + &"/xrpc/com.atproto.server.createSession".to_string();
    let f = token_file(&"json");
    let handle = cfg(&"user");
    let pass = cfg(&"pass");
    let mut map = HashMap::new();

    //map.insert("did", &did);
    map.insert("identifier", &handle);
    map.insert("password", &pass);
    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .json(&map)
        .send()
        .await?
        .text()
        .await?;
    let j = Json::from_str(&res).unwrap();
    let j = j.to_string();
    println!("{}", j);
    let mut f = fs::File::create(f).unwrap();
    if j != "" {
        f.write_all(&j.as_bytes()).unwrap();
    }

    let f = token_file(&"toml");
    let json: Token = serde_json::from_str(&res).unwrap();
    let tokens = Tokens {
        did: json.did.to_string(),
        access: json.accessJwt.to_string(),
        refresh: json.refreshJwt.to_string(),
        handle: json.handle.to_string(),
    };

    let toml = toml::to_string(&tokens).unwrap();
    let mut f = fs::File::create(f.clone()).unwrap();
    f.write_all(&toml.as_bytes()).unwrap();
    Ok(())
}

fn a_token(_c: &Context) {
    w_token().unwrap();
    w_refresh().unwrap();
}

#[tokio::main]
async fn aa() -> reqwest::Result<()> {
    let host = cfg(&"host");
    let url = url(&"session_get");
    let access = token_toml(&"access");
    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .header("Authorization", "Bearer ".to_owned() + &access)
        .send()
        .await?;
    let status_ref = res.error_for_status_ref();
    match status_ref {
        Ok(_) => {
        },
        Err(_e) => {
            // refresh token
            let f = token_file(&"json");
            let refresh = token_toml(&"refresh");
            let url = "https://".to_string() + &host.to_string() + &"/xrpc/com.atproto.server.refreshSession".to_string();
            let client = reqwest::Client::new();
            let res = client
                .post(url)
                .header("Authorization", "Bearer ".to_owned() + &refresh)
                .send()
                .await?
                .text()
                .await?;
            let j = Json::from_str(&res).unwrap();
            let j = j.to_string();
            println!("{}", j);
            let mut f = fs::File::create(f).unwrap();
            if j != "" {
                f.write_all(&j.as_bytes()).unwrap();
            }

            let f = token_file(&"toml");
            let json: Token = serde_json::from_str(&res).unwrap();
            let tokens = Tokens {
                did: json.did.to_string(),
                access: json.accessJwt.to_string(),
                refresh: json.refreshJwt.to_string(),
                handle: json.handle.to_string(),
            };

            let toml = toml::to_string(&tokens).unwrap();
            let mut f = fs::File::create(f.clone()).unwrap();
            f.write_all(&toml.as_bytes()).unwrap();
        }
    }
    
    Ok(())
}

fn a(_c: &Context) {
    aa().unwrap();
}

fn pp(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        if let Ok(link) = c.string_flag("link") {
            let e = link.chars().count();
            let s = 0;
            let str = at_post_link::post_request(m.to_string(), link.to_string(), s, e.try_into().unwrap());
            println!("{}",str.await);
        } else {
            let str = at_post::post_request(m.to_string());
            println!("{}",str.await);
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn like_c(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        if let Ok(uri) = c.string_flag("uri") {
            let str = at_like::post_request(m.to_string(), uri);
            println!("{}",str.await);
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn like(c: &Context) {
    aa().unwrap();
    like_c(c);
}

fn repost_c(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        if let Ok(uri) = c.string_flag("uri") {
            let str = at_repost::post_request(m.to_string(), uri);
            println!("{}",str.await);
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn repost(c: &Context) {
    aa().unwrap();
    repost_c(c);
}

fn follow_c(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        let str = at_follow::post_request(m.to_string());
        println!("{}",str.await);
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn follow_c_d(c: &Context, delete: String) {
    let m = c.args[0].to_string();
    let h = async {
        let str = at_follow::delete_request(m.to_string(), delete.to_string());
        println!("{}",str.await);
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn follow_c_all(_c: &Context) {
    let file = "/.config/atr/scpt/follow_all.zsh";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);
    use std::process::Command;
    let output = Command::new(&f).output().expect("zsh");
    let d = String::from_utf8_lossy(&output.stdout);
    let d = "\n".to_owned() + &d.to_string();
    println!("{}", d);
}

fn follows_c(c: &Context) {
    let h = async {
        let handle = cfg(&"user");
        if let Ok(cursor) = c.string_flag("cursor") {
            let str = at_follows::get_request(handle,Some(cursor.to_string()));
            println!("{}",str.await);
        } else {
            let str = at_follows::get_request(handle,Some("".to_string()));
            println!("{}",str.await);
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);

    return res
} 

fn followers_c(c: &Context) {
    let h = async {
        let handle = cfg(&"user");
        if let Ok(cursor) = c.string_flag("cursor") {
            let str = at_followers::get_request(handle,Some(cursor.to_string()));
            println!("{}",str.await);
        } else {
            let str = at_followers::get_request(handle,Some("".to_string()));
            println!("{}",str.await);
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
} 

fn follow(c: &Context) {
    aa().unwrap();
    if c.bool_flag("follows") {
        follows_c(c);
    } else if c.bool_flag("followers") {
        followers_c(c);
    } else if c.bool_flag("all") {
        follow_c_all(c);
    } else {
        if let Ok(delete) = c.string_flag("delete") {
            follow_c_d(c, delete);
        } else {
            follow_c(c);
        }
    }
}

fn tt(c: &Context) {
    let h = async {
        let j = at_timeline::get_request().await;
        let timeline: Timeline = serde_json::from_str(&j).unwrap();
        let n = timeline.feed;
        let mut map = HashMap::new();

        if c.bool_flag("json") {
            println!("{}", j);
        } else if c.bool_flag("latest") {
            map.insert("handle", &n[0].post.author.handle);
            map.insert("uri", &n[0].post.uri);
            if ! n[0].post.record.text.is_none() { 
                map.insert("text", &n[0].post.record.text.as_ref().unwrap());
            } 
            println!("{:?}", map);
        } else {
            let length = &n.len();
            for i in 0..*length {
                println!("@{}", n[i].post.author.handle);
                if ! n[i].post.record.text.is_none() { 
                    println!("{}", n[i].post.record.text.as_ref().unwrap());
                } else {
                }
                println!("uri : {}", n[i].post.uri);
                println!("cid : {}", n[i].post.cid);
                println!("⚡️ [{}]\t🌈 [{}]\t⭐️ [{}]", n[i].post.replyCount,n[i].post.replyCount, n[i].post.likeCount);
                println!("{}", "---------");
            }
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn t(c: &Context) {
    aa().unwrap();
    tt(c);
}

fn pro(u: String) {
    let h = async {
        let str = at_profile::get_request(u.to_string());
        println!("{}", str.await);
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn prop(u: String) {
    let h = async {
        let str = at_profile::get_request(u.to_string());
        let profile: Profile = serde_json::from_str(&str.await).unwrap();
        println!("{}", profile.postsCount);
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn profile(c: &Context) {
    aa().unwrap();
    let user = cfg(&"user");
    if c.args.len() == 0 {
        pro(user);
    } else if c.bool_flag("post") {
        let m = c.args[0].to_string();
        prop(m);
    } else {
        let m = c.args[0].to_string();
        pro(m);
    }
}

#[tokio::main]
async fn mm(c: &Context) -> reqwest::Result<()> {
    
    let token = token_toml(&"access");

    let atoken = "Authorization: Bearer ".to_owned() + &token;
    let con = "Content-Type: image/png";
    let did = token_toml(&"did");

    let host = cfg(&"host");
    let url = url(&"upload_blob");

    let f = "@".to_owned() + &c.args[0].to_string();
    use std::process::Command;
    let output = Command::new("curl").arg("-X").arg("POST").arg("-sL").arg("-H").arg(&con).arg("-H").arg(&atoken).arg("--data-binary").arg(&f).arg(&url).output().expect("curl");
    let d = String::from_utf8_lossy(&output.stdout);
    let d =  d.to_string();
    let cid: Cid = serde_json::from_str(&d).unwrap();

    let d = Timestamp::now_utc();
    let d = d.to_string();
    println!("{}", d);

    let mtype = "image/png".to_string();

    //let url = url(&"record_create");
    let url = "https://".to_owned() + &host + &"/xrpc/com.atproto.repo.createRecord";
    let con = "Content-Type: application/json";

    let cid = cid.cid;
    let j = "{\"did\":\"".to_owned() + &did + &"\",\"collection\":\"app.bsky.feed.post\",\"record\":{\"text\":\"\",\"createdAt\":\"" + &d + &"\", \"embed\": {\"$type\":\"app.bsky.embed.images\",\"images\":[{\"image\":{\"cid\":\"" + &cid + &"\",\"mimeType\":\"" + &mtype + &"\"},\"alt\":\"\"}]}}}".to_string();
    println!("{}", j);

    let output = Command::new("curl").arg("-X").arg("POST").arg("-sL").arg("-H").arg(&con).arg("-H").arg(&atoken).arg("-d").arg(&j).arg(&url).output().expect("curl");
    let d = String::from_utf8_lossy(&output.stdout);
    let d =  d.to_string();
    println!("{:#?}", d);
    Ok(())
}

fn m(c: &Context) {
    aa().unwrap();
    mm(c).unwrap();
}


#[tokio::main]
async fn img_upload_run(c: &Context) -> reqwest::Result<()> {
    let token = token_toml(&"access");
    let atoken = "Authorization: Bearer ".to_owned() + &token;
    let con = "Content-Type: image/jpeg";
    //let did = token_toml(&"did");

    //let host = cfg(&"host");
    let url = url(&"upload_blob");

    let f = "@".to_owned() + &c.args[0].to_string();
    use std::process::Command;
    let output = Command::new("curl").arg("-X").arg("POST").arg("-sL").arg("-H").arg(&con).arg("-H").arg(&atoken).arg("--data-binary").arg(&f).arg(&url).output().expect("curl");
    let d = String::from_utf8_lossy(&output.stdout);
    let d =  d.to_string();
    println!("{}", d);
    Ok(())
}

fn img_upload(c: &Context) {
    aa().unwrap();
    img_upload_run(c).unwrap();
}

fn img_post(c: &Context) {
    let m = c.args[0].to_string();
    if let Ok(link) = c.string_flag("link") {
        if let Ok(cid) = c.string_flag("cid") {
            if let Ok(uri) = c.string_flag("uri") {
                let h = async {
                    let itype = "image/jpeg";
                    let str = at_img_reply::post_request(m.to_string(),link.to_string(),cid.to_string(),uri.to_string(), itype.to_string());
                    println!("{}",str.await);
                };
                tokio::runtime::Runtime::new().unwrap().block_on(h);
            }
        } else {
            let h = async {
                let str = at_img::post_request(m.to_string(),link.to_string());
                println!("{}",str.await);
            };
            tokio::runtime::Runtime::new().unwrap().block_on(h);
        }
    }
}

fn reply_og(c: &Context) {
    let m = c.args[0].to_string();
    if let Ok(link) = c.string_flag("link") {
        if let Ok(cid) = c.string_flag("cid") {
            if let Ok(uri) = c.string_flag("uri") {
                if let Ok(title) = c.string_flag("title") {
                    if let Ok(description) = c.string_flag("description") {
                        if let Ok(img) = c.string_flag("img") {
                            let h = async {
                                let str = at_reply_og::post_request(m.to_string(),link.to_string(),cid.to_string(),uri.to_string(), img.to_string(), title.to_string(), description.to_string());
                                println!("{}",str.await);
                            };
                            tokio::runtime::Runtime::new().unwrap().block_on(h);
                        }
                    }
                }
            }
        }
    }
}

fn hh(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        let str = at_handle_update::post_request(m.to_string());
        println!("{}", str.await);
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn h(c: &Context) {
    aa().unwrap();
    hh(c);
}

#[tokio::main]
async fn cc(c: &Context) -> reqwest::Result<()> {

    let url = url(&"account_create");
    //let handle = token_toml(&"handle");
    let handle = cfg(&"user");
    let pass = cfg(&"pass");

    let mut map = HashMap::new();
    map.insert("handle", &handle);
    map.insert("password", &pass);

    if let Ok(invite) = c.string_flag("invite") {
        if let Ok(email) = c.string_flag("email") {
            map.insert("inviteCode", &invite);
            map.insert("email", &email);
            let client = reqwest::Client::new();
            let res = client
                .post(url)
                .json(&map)
                .send()
                .await?
                .text()
                .await?;
            println!("{}", res);
        }
    }
    Ok(())
}

fn c(c: &Context) {
    cc(c).unwrap();
}

fn mention(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        let str = at_profile::get_request(m.to_string()).await;
        let profile: Profile = serde_json::from_str(&str).unwrap();
        let udid = profile.did;
        let handle = profile.handle;
        let at = "@".to_owned() + &handle;
        let e = at.chars().count();
        let s = 0;
        if let Ok(post) = c.string_flag("post") {
            let str = at_mention::post_request(post.to_string(), at.to_string(), udid.to_string(), s, e.try_into().unwrap()).await;
            println!("{}",str);
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn mention_run(c: &Context) {
    aa().unwrap();
    mention(c);
}

fn nn(c: &Context, limit: i32, check: bool) {
    let h = async {
        let str = at_notify_limit::get_request(limit);
        let notify: Notify = serde_json::from_str(&str.await).unwrap();
        let n = notify.notifications;
        let length = &n.len();
        for i in 0..*length {
            let reason = &n[i].reason;
            let handle = &n[i].author.handle;
            let read = n[i].isRead;
            let time = &n[i].indexedAt;
            let cid = &n[i].cid;
            let uri = &n[i].uri;
            if c.bool_flag("clean") {
                let str_notify = at_notify_read::post_request(time.to_string()).await;
                println!("{}", str_notify);
            }
            if read == check {
                if ! n[i].record.text.is_none() { 
                    let text = &n[i].record.text.as_ref().unwrap();
                    println!("{}\n[{}]{}\n{}", handle, reason, read, text);
                    println!("{}\ncid:{}\turi:{}", time, cid, uri);
                    println!("{}", "---------");
                }
            }
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn notify_all(_c: &Context) {
    aa().unwrap();
    let h = async {
        let j = at_notify_limit::get_request(100).await;
        println!("{}", j);
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn cid_check_run(cid :String) -> bool {
    let file = "/.config/atr/notify_cid_run.txt";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);
    let mut file = match OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .append(true)
        .open(f.clone())
        {
            Err(why) => panic!("Couldn't open {}: {}", f, why),
            Ok(file) => file,
        };
    let mut contents = String::new();
    match file.read_to_string(&mut contents) {
        Err(why) => panic!("Couldn't read {}: {}", f, why),
        Ok(_) => (),
    }
    if contents.contains(&cid) == false {
        let check = false;
        return check
    } else { 
        let check = true;
        return check 
    }
}

fn cid_write_run(cid :String) -> bool {
    let file = "/.config/atr/notify_cid_run.txt";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);
    let mut file = match OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .append(true)
        .open(f.clone())
        {
            Err(why) => panic!("Couldn't open {}: {}", f, why),
            Ok(file) => file,
        };
    let mut contents = String::new();
    match file.read_to_string(&mut contents) {
        Err(why) => panic!("Couldn't read {}: {}", f, why),
        Ok(_) => (),
    }
    if contents.contains(&cid) == false {
        let cid = cid + "\n";
        println!("contents:\n{}", contents);
        match file.write_all(cid.as_bytes()) {
            Err(why) => panic!("Couldn't write \"{}\" to {}: {}", contents, f, why),
            Ok(_) => println!("finished"),
        }
        let check = false;
        return check
    } else { 
        let check = true;
        return check 
    }
}

fn cid_check(cid :String) -> bool {
    let file = "/.config/atr/notify_cid.txt";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);
    let mut file = match OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .append(true)
        .open(f.clone())
        {
            Err(why) => panic!("Couldn't open {}: {}", f, why),
            Ok(file) => file,
        };
    let mut contents = String::new();
    match file.read_to_string(&mut contents) {
        Err(why) => panic!("Couldn't read {}: {}", f, why),
        Ok(_) => (),
    }
    if contents.contains(&cid) == false {
        let check = false;
        return check
    } else { 
        let check = true;
        return check 
    }
}

fn cid_write(cid :String) -> bool {
    let file = "/.config/atr/notify_cid.txt";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);
    let mut file = match OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .append(true)
        .open(f.clone())
        {
            Err(why) => panic!("Couldn't open {}: {}", f, why),
            Ok(file) => file,
        };
    let mut contents = String::new();
    match file.read_to_string(&mut contents) {
        Err(why) => panic!("Couldn't read {}: {}", f, why),
        Ok(_) => (),
    }
    if contents.contains(&cid) == false {
        let cid = cid + "\n";
        println!("contents:\n{}", contents);
        match file.write_all(cid.as_bytes()) {
            Err(why) => panic!("Couldn't write \"{}\" to {}: {}", contents, f, why),
            Ok(_) => println!("finished"),
        }
        let check = false;
        return check
    } else { 
        let check = true;
        return check 
    }
}

fn nn_cid() {
    let h = async {
        let str = at_notify_limit::get_request(20);
        let notify: Notify = serde_json::from_str(&str.await).unwrap();
        let n = notify.notifications;
        let length = &n.len();
        for i in 0..*length {
            let cid = &n[i].cid;
            cid_write(cid.to_string());
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn n(c: &Context) {
    aa().unwrap();
    let limit = 10;
    if c.bool_flag("latest") {
        let limit = 1;
        nn(c, limit, true);
    } else if let Ok(limit) = c.int_flag("limit") {
        nn(c, limit.try_into().unwrap(), true);
    } else if c.bool_flag("check") {
        let check = false;
        nn(c, limit.try_into().unwrap(), check);
    } else if c.bool_flag("cid") {
        nn_cid();
    } else {
        nn(c, limit, true);
    }
}

fn get_domain_zsh() {
    //let handle = token_toml(&"handle");
    let handle = cfg(&"user");
    let e = "export BLUESKY_BASE=".to_owned() + &handle.to_string() + "\n";
    let e = e.to_string();
    let f = shellexpand::tilde("~") + "/.config/atr/atr.zsh";
    let f = f.to_string();
    let r = shellexpand::tilde("~") + "/.config/atr/atr.zsh";
    let r = r.to_string();
    fs::remove_file(r).unwrap_or_else(|why| {
        println!("! {:?}", why.kind());
    });
    let mut f = fs::File::create(f).unwrap();
    f.write_all(e.as_bytes()).unwrap();
}

//#[allow(unused_must_use)]
//fn account_switch_bot(i: String)  {
//    let o = shellexpand::tilde("~") + "/.config/atr/config.toml";
//    let o = o.to_string();
//    if &i == "-d" {
//        let i = shellexpand::tilde("~") + "/.config/atr/setting.toml";
//        let i = i.to_string();
//        println!("{:#?} -> {:#?}", i, o);
//        let check = Path::new(&i).exists();
//        if check == false {
//            fs::copy(o, i);
//        } else {
//            fs::copy(i, o);
//        }
//    } else if &i == "-s" {
//        let i = shellexpand::tilde("~") + "/.config/atr/social.toml";
//        let i = i.to_string();
//        println!("{:#?} -> {:#?}", i, o);
//        let check = Path::new(&i).exists();
//        if check == false {
//            fs::copy(o, i);
//        } else {
//            fs::copy(i, o);
//        }
//    } else {
//        println!("{:#?} -> {:#?}", i, o);
//        let check = Path::new(&i).exists();
//        if check == false {
//            fs::copy(o, i);
//        } else {
//            fs::copy(i, o);
//        }
//    }
//    aa().unwrap();
//}

#[allow(unused_must_use)]
fn account_switch(c: &Context)  {
    let i = c.args[0].to_string();
    let o = shellexpand::tilde("~") + "/.config/atr/config.toml";
    let o = o.to_string();
    if &i == "-d" {
        let i = shellexpand::tilde("~") + "/.config/atr/setting.toml";
        let i = i.to_string();
        println!("{:#?} -> {:#?}", i, o);
        let check = Path::new(&i).exists();
        if check == false {
            fs::copy(o, i);
        } else {
            fs::copy(i, o);
        }
    } else if &i == "-s" {
        let i = shellexpand::tilde("~") + "/.config/atr/social.toml";
        let i = i.to_string();
        println!("{:#?} -> {:#?}", i, o);
        let check = Path::new(&i).exists();
        if check == false {
            fs::copy(o, i);
        } else {
            fs::copy(i, o);
        }
    } else {
        println!("{:#?} -> {:#?}", i, o);
        let check = Path::new(&i).exists();
        if check == false {
            fs::copy(o, i);
        } else {
            fs::copy(i, o);
        }
    }
    get_domain_zsh();
    ss(c).unwrap();
}

#[allow(unused_must_use)]
fn first_start(c: &Context) -> io::Result<()> {
    let d = shellexpand::tilde("~") + "/.config/atr";
    let d = d.to_string();
    let f = shellexpand::tilde("~") + "/.config/atr/config.toml";
    let f = f.to_string();

    let setting = Setting {
        host: "bsky.social".to_string(),
        user: "".to_string(),
        pass: "".to_string(),
    };
    let toml = toml::to_string(&setting).unwrap();

    let check = Path::new(&d).exists();
    if check == false {
        fs::create_dir_all(d);
        let mut f = fs::File::create(f.clone()).unwrap();
        f.write_all(&toml.as_bytes()).unwrap();
    }
    let check = Path::new(&f).exists();
    if check == false {
        let mut f = fs::File::create(f.clone()).unwrap();
        f.write_all(&toml.as_bytes()).unwrap();
    }

    let f = shellexpand::tilde("~") + "/.config/atr/config.toml";
    let f = f.to_string();

    if let Ok(user) = c.string_flag("user") {
        if let Ok(pass) = c.string_flag("pass") {
            let setting = Setting {
                host: "bsky.social".to_string(),
                user: user.to_string(),
                pass: pass.to_string(),
            };
            let toml = toml::to_string(&setting).unwrap();
            let mut f = fs::File::create(f.clone()).unwrap();
            f.write_all(&toml.as_bytes()).unwrap();
        }
    }
    Ok(())
}



fn first(c: &Context) {
    first_start(c).unwrap();
}

fn rr(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        if let Ok(cid) = c.string_flag("cid") {
            if let Ok(uri) = c.string_flag("uri") {
                if let Ok(link) = c.string_flag("link") {
                    let s = 0;
                    let e = link.chars().count();
                    let str = at_reply_link::post_request(m.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                    println!("{}", str);
                } else {
                    let str = at_reply::post_request(m.to_string(), cid.to_string(), uri.to_string()).await;
                    println!("{}", str);
                }
            } 
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn r(c: &Context) {
    aa().unwrap();
    rr(c);
}

#[allow(unused_must_use)]
fn deepl_read(c: &Context) {
    if let Ok(lang) = c.string_flag("lang") {
        ppd(c, &lang, false);
    } else {
        ppd(c, &"ja", false);
    }
}

#[allow(unused_must_use)]
fn deepl_api(c: &Context) {
    let api = c.args[0].to_string();
    let o = "api='".to_owned() + &api.to_string() + &"'".to_owned();
    let o = o.to_string();
    let l = shellexpand::tilde("~") + "/.config/atr/deepl.toml";
    let l = l.to_string();
    let mut l = fs::File::create(l).unwrap();
    if o != "" {
        l.write_all(&o.as_bytes()).unwrap();
    }
    println!("{:#?}", l);
}

fn ppd(c: &Context, lang: &str, check_post: bool) {
    let m = c.args[0].to_string();
    let lang = lang.to_string();
    let h = async {
        let str_openai = deepl::post_request(m.to_string(), lang.to_string()).await;
        println!("{}", str_openai);
        if check_post == true {
            let text_limit = char_c(str_openai);
            let str_rep = at_post::post_request(text_limit.to_string()).await;
            println!("{}", str_rep); 
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

#[allow(unused_must_use)]
fn openai_read(c: &Context) {
    if let Ok(model) = c.string_flag("model") {
        ppc(c, &model, false);
    } else if c.bool_flag("char") {
        ppc_char(c);
    } else {
        let model = "text-davinci-003";
        ppc(c, &model, false);
    }
}

#[allow(unused_must_use)]
fn openai_api(c: &Context) {
    let api = c.args[0].to_string();
    let o = "api='".to_owned() + &api.to_string() + &"'".to_owned();
    let o = o.to_string();
    let l = shellexpand::tilde("~") + "/.config/atr/openai.toml";
    let l = l.to_string();
    let mut l = fs::File::create(l).unwrap();
    if o != "" {
        l.write_all(&o.as_bytes()).unwrap();
    }
    println!("{:#?}", l);
}

fn ppc(c: &Context, model: &str, check_post: bool) {
    let m = c.args[0].to_string();
    let model = model.to_string();
    let h = async {
        let str_openai = openai::post_request(m.to_string(),model.to_string()).await;
        if check_post == true {
            let text_limit = char_c(str_openai);
            let str_rep = at_post::post_request(text_limit.to_string()).await;
            println!("{}", str_rep); 
        } else { 
            println!("{}", str_openai); 
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn ppc_char(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        let str_openai = openai_char::post_request(m.to_string()).await;
        println!("{}", str_openai); 
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn p(c: &Context) {
    aa().unwrap();
    if c.bool_flag("en") {
        ppd(c, &"en", true);
    } else if c.bool_flag("ja") {
        ppd(c, &"ja", true);
    } else if c.bool_flag("chat") {
        ppc(c, &"text-davinci-003", true);
    } else {
        pp(c);
    }
}

pub fn char_c(i: String) -> String {
    let l = 250;
    let mut s = String::new();
    for ii in i.chars().enumerate() {
        match ii.0 {
            n if n > l.try_into().unwrap() => {break}
            _ => {s.push(ii.1)}
        }
    }
    return s
}

#[allow(unused_must_use)]
fn bot_run_timeline(_c: &Context) {
    //account_switch_bot("-s".to_string());
    let h = async {
        let j = at_timeline::get_request().await;
        let timeline: Timeline = serde_json::from_str(&j).unwrap();
        let n = timeline.feed;

        let length = &n.len();
        for i in 0..*length {
            let _reason = &n[i].post.reason;
            let handle = &n[i].post.author.handle;
            let did = &n[i].post.author.did;
            let cid = &n[i].post.cid;
            let c_ch = cid_check(cid.to_string());
            if c_ch == false {
                let _time = &n[i].post.indexedAt;
                let uri = &n[i].post.uri;
                if ! n[i].post.record.text.is_none() { 
                    let text = &n[i].post.record.text.as_ref().unwrap();
                    let vec: Vec<&str> = text.split_whitespace().collect();
                    let com = vec[0].trim().to_string();
                    if com.contains("/占") == true || com.contains("/うらな") == true {
                        let file = "/.config/atr/scpt/card_fortune.zsh";
                        let mut f = shellexpand::tilde("~").to_string();
                        f.push_str(&file);
                        use std::process::Command;

                        let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                        let d = String::from_utf8_lossy(&output.stdout);
                        let d = d.to_string();
                        let text_limit = char_c(d);
                        if text_limit.len() > 3 {
                            println!("{}", text_limit);
                            cid_write(cid.to_string());
                        }
                    } else if com.contains("アイ") == true || com.contains("ユイ") == true || com.contains("ai") == true || com.contains("yui") == true {

                        let prompt = &vec[1..].join(" ");

                        let file = "/.config/atr/scpt/openai_like_timeline.zsh";
                        let mut f = shellexpand::tilde("~").to_string();
                        f.push_str(&file);
                        use std::process::Command;
                        let output = Command::new(&f).arg(&cid).arg(&uri).arg(&prompt).output().expect("zsh");
                        let d = String::from_utf8_lossy(&output.stdout);
                        println!("{}", d);
                        cid_write(cid.to_string());
                    }
                }
            }
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn bot_timeline(c: &Context) {
    aa().unwrap();
    bot_run_timeline(c);
}

fn bot_run_change(_c: &Context, mode: bool) {
    let h = async {
        let str = at_notify_limit::get_request(30);
        let notify: Notify = serde_json::from_str(&str.await).unwrap();
        let n = notify.notifications;
        let length = &n.len();
        let su = (0..*length).rev();
        for i in su {
            let reason = &n[i].reason;
            let read = n[i].isRead;
            let cid = &n[i].cid;
            let c_ch = cid_check(cid.to_string());
            let c_ch_run = cid_check_run(cid.to_string());
            println!("{}", read);
            if c_ch_run == false && { reason == "mention" || reason == "reply" } || mode == true && c_ch_run == true && c_ch == false && { reason == "mention" || reason == "reply" } {
                cid_write_run(cid.to_string());
                if mode == true {
                    println!("---\nmode:{}\ncid:{}\n---", mode, cid);
                }
                let uri = &n[i].uri;
                if ! n[i].record.text.is_none() { 
                    let cc_ch = cid_check(cid.to_string());
                    if cc_ch == false {
                        let text_limit = "change -> @yui.syui.ai\n/off";
                        let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                        println!("{}", str_rep);
                        cid_write(cid.to_string());
                    }
                }
            }
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn bot_change(c: &Context) {
    aa().unwrap();
    let mode = c.bool_flag("mode");
    bot_run_change(c, mode);
}

fn bot_run(_c: &Context, limit: i32, admin: String, mode: bool) {
    let h = async {
        let str = at_notify_limit::get_request(limit);
        let notify: Notify = serde_json::from_str(&str.await).unwrap();
        let n = notify.notifications;
        let length = &n.len();
        let su = 0..*length;
        //let su = (0..*length).rev();
        for i in su {
            let reason = &n[i].reason;
            let handle = &n[i].author.handle;
            //let d_name = &n[i].author.displayName;
            let did = &n[i].author.did;
            let read = n[i].isRead;
            let cid = &n[i].cid;
            let c_ch = cid_check(cid.to_string());
            let c_ch_run = cid_check_run(cid.to_string());
            println!("{}", read);
            if c_ch_run == false && { reason == "mention" || reason == "reply" } || mode == true && c_ch_run == true && c_ch == false && { reason == "mention" || reason == "reply" } {
                cid_write_run(cid.to_string());
                if mode == true {
                    println!("---\nmode:{}\ncid:{}\n---", mode, cid);
                }
                let time = &n[i].indexedAt;
                let uri = &n[i].uri;
                if ! n[i].record.text.is_none() { 
                    let text = &n[i].record.text.as_ref().unwrap();
                    let vec: Vec<&str> = text.split_whitespace().collect();
                    let rep_com = &vec[0..].join(" ");
                    if reason == "reply" && { rep_com.contains("占") == true || rep_com.contains("タロット") == true } {
                        let file = "/.config/atr/scpt/card_tarot.zsh";
                        let mut f = shellexpand::tilde("~").to_string();
                        f.push_str(&file);
                        use std::process::Command;

                        let cc_ch = cid_check(cid.to_string());
                        if cc_ch == false {
                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d = d.to_string();
                            let text_limit = char_c(d);
                            if text_limit.len() > 3 {
                                println!("{}", text_limit);
                                cid_write(cid.to_string());
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                            }
                        }
                    } else if reason == "reply" && { rep_com.contains("fortune") == true || rep_com.contains("tarot") == true } {
                        let file = "/.config/atr/scpt/card_tarot_en.zsh";
                        let mut f = shellexpand::tilde("~").to_string();
                        f.push_str(&file);
                        use std::process::Command;

                        let cc_ch = cid_check(cid.to_string());
                        if cc_ch == false {
                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d = d.to_string();
                            let text_limit = char_c(d);
                            if text_limit.len() > 3 {
                                println!("{}", text_limit);
                                cid_write(cid.to_string());
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                            }
                        }
                    } else if reason == "reply" && rep_com.contains("card") == true {
                        let prompt = &vec[1..].join(" ");
                        let file = "/.config/atr/scpt/api_card.zsh";
                        let mut f = shellexpand::tilde("~").to_string();
                        f.push_str(&file);
                        use std::process::Command;
                        let cc_ch = cid_check(cid.to_string());
                        if cc_ch == false {
                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let handlev: Vec<&str> = handle.split('.').collect();
                            let handlev = handlev[0].trim().to_string();
                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);
                            let dd = "\n".to_owned() + &d.to_string();
                            let text_limit = char_c(dd);
                            println!("{}", text_limit);
                            if text_limit.len() > 3 {
                                if d.contains("handle") == false {
                                    let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                } else {
                                    let handlev = handle.replace(".", "-").to_string();
                                    let link = "https://card.syui.ai/".to_owned() + &handlev;
                                    let s = 0;
                                    let e = link.chars().count();
                                    let str_rep = at_reply_link::post_request(d.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                }
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        }
                    } else if reason == "reply" && { rep_com.contains("fav") == true || rep_com.contains("fab") == true } {
                        let prompt = &vec[1..].join(" ");
                        let file = "/.config/atr/scpt/api_fav.zsh";
                        let mut f = shellexpand::tilde("~").to_string();
                        f.push_str(&file);
                        use std::process::Command;
                        let cc_ch = cid_check(cid.to_string());
                        if cc_ch == false {
                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let handlev: Vec<&str> = handle.split('.').collect();
                            let handlev = handlev[0].trim().to_string();
                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);
                            let dd = "\n".to_owned() + &d.to_string();
                            let text_limit = char_c(dd);
                            println!("{}", text_limit);
                            if text_limit.len() > 3 {
                                let str_rep = at_reply_link::post_request(d.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        }
                    } else if reason == "reply" && rep_com.contains("ten") == true {
                        let cc_ch = cid_check(cid.to_string());
                        if cc_ch == false {
                            cid_write(cid.to_string());
                            let option = &vec[1..].join(" ");
                            let file = "/.config/atr/scpt/api_ten.zsh";
                            let sub_option = &vec[2..].join(" ");
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).arg(&option).arg(&sub_option).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            // test reply link
                            let handlev: Vec<&str> = handle.split('.').collect();
                            let handlev = handlev[0].trim().to_string();
                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);
                            let d = "\n".to_owned() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);
                            if text_limit.len() > 3 {
                                let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                            } else {
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                            }
                        }
                    } else if reason == "reply" && rep_com.contains("chara") == true {
                        let cc_ch = cid_check(cid.to_string());
                        if cc_ch == false {
                            cid_write(cid.to_string());
                            let option = &vec[1..].join(" ");
                            let file = "/.config/atr/scpt/api_chara.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).arg(&option).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            // test reply link
                            let handlev: Vec<&str> = handle.split('.').collect();
                            let handlev = handlev[0].trim().to_string();
                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);
                            let d = "\n".to_owned() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);
                            if text_limit.len() > 3 {
                                let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                            } else {
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                            }
                        }
                    } else if reason == "reply"  && rep_com.contains("off") == false {
                        let str_notify = at_notify_read::post_request(time.to_string()).await;
                        println!("{}", str_notify);
                        let prompt = &vec[0..].join(" ");
                        println!("prompt:{}", prompt);
                        println!("cid:{}, uri:{}", cid, uri);
                        println!("{}", text);
                        //let model = "text-davinci-003";
                        //let str_openai = openai::post_request(prompt.to_string(),model.to_string()).await;
                        let str_openai = openai_char::post_request(prompt.to_string()).await;
                        println!("{}", str_openai);
                        let text_limit = char_c(str_openai);

                        // save like
                        let file = "/.config/atr/scpt/openai_like.zsh";
                        let mut f = shellexpand::tilde("~").to_string();
                        f.push_str(&file);
                        use std::process::Command;
                        Command::new(&f).arg(&handle).arg(&did).arg(&text_limit).output().expect("zsh");

                        let cc_ch = cid_check(cid.to_string());
                        if cc_ch == false {
                            let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                            println!("{}", str_rep);
                            cid_write(cid.to_string());
                        }
                    }
                    let ccc_ch = cid_check(cid.to_string());
                    if vec.len() > 1 && ccc_ch == false {
                        let com = vec[1].trim().to_string();
                        let cccc_ch = cid_check(cid.to_string());
                        if com == "/chat"  && { handle == &admin } {
                            let prompt = &vec[2..].join(" ");
                            println!("cmd:{}, prompt:{}", com, prompt);
                            println!("cid:{}, uri:{}", cid, uri);
                            println!("{}", text);
                            let model = "text-davinci-003";
                            let str_openai = openai::post_request(prompt.to_string(),model.to_string()).await;
                            println!("{}", str_openai);
                            let text_limit = char_c(str_openai);
                            let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                            println!("{}", str_rep);
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);
                            cid_write(cid.to_string());
                        } else if com == "/deepl" && { handle == &admin } {
                            let lang = &vec[2].to_string();
                            let prompt = &vec[3..].join(" ");
                            println!("cmd:{}, lang:{}, prompt:{}", com, lang, prompt);
                            println!("cid:{}, uri:{}", cid, uri);
                            println!("{}", text);
                            let str_deepl = deepl::post_request(prompt.to_string(),lang.to_string()).await;
                            println!("{}", str_deepl);
                            let text_limit = char_c(str_deepl);
                            let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                            println!("{}", str_rep);
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);
                            cid_write(cid.to_string());
                        } else if { com == "sh" || com == "/sh" } && handle == &admin {
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);

                            let prompt = &vec[2..].join(" ");
                            println!("cmd:{}, prompt:{}", com, prompt);
                            println!("cid:{}, uri:{}", cid, uri);
                            println!("{}", text);
                            let file = "/.config/atr/scpt/arch.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let output = Command::new(&f).arg(&prompt).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d =  d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                            println!("{}", str_rep);
                            cid_write(cid.to_string());
                        } else if com == "/diffusion" && { handle == &admin } {
                            let prompt = &vec[2..].join(" ");
                            println!("cmd:{}, prompt:{}", com, prompt);
                            let file = "/.config/atr/scpt/diffusion.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let output = Command::new(&f).arg(&prompt).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d =  d.to_string();
                            println!("{}", d);
                            let file = "/.config/atr/scpt/at_img.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            let output = Command::new(&f).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let link =  d.to_string();
                            let text_limit = "#stablediffusion";
                            let itype = "image/jpeg";
                            let str_rep = at_img_reply::post_request(text_limit.to_string(), link.to_string(), cid.to_string(), uri.to_string(), itype.to_string()).await;
                            println!("{}", str_rep);
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);
                            cid_write(cid.to_string());
                        } else if com == "/s" || com == "search" || com == "-s" {
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);
                            let prompt = &vec[2..].join(" ");
                            println!("cmd:{}, prompt:{}", com, prompt);
                            println!("cid:{}, uri:{}", cid, uri);
                            println!("{}", text);
                            let file = "/.config/atr/scpt/at_search.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let output = Command::new(&f).arg(&prompt).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d =  d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                            println!("{}", str_rep);
                            cid_write(cid.to_string());
                        } else if com == "/reset" {
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);
                            let file = "/.config/atr/scpt/openai_like_bot.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let output = Command::new(&f).arg(&handle).arg("reset").output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d =  d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                            println!("{}", str_rep);
                            cid_write(cid.to_string());
                        } else if com == "date" || com == "/date" {
                            let d = Timestamp::now_utc();
                            let d = "utc ".to_owned() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);
                            if text_limit.len() > 3 {
                                let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        } else if com == "did" || com == "/did" {
                            let link = "https://plc.directory/".to_owned() + &did + &"/log";
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);

                            let d = "\n".to_owned() + &did.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);

                            if text_limit.len() > 3 {
                                let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        } else if com == "handle" || com == "/handle" || com == "-h" {
                            let user = &vec[2].to_string();
                            let res = at_user_status::get_request(user.to_string()).await;
                            let status: Status = serde_json::from_str(&res).unwrap();
                            let link = "https://plc.directory/".to_owned() + &status.did.to_string() + &"/log";

                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);

                            let file = "/.config/atr/scpt/dig.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let output = Command::new(&f).arg(&user).arg(&status.did).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d = "\n".to_owned() + &status.did.to_string() + &"\n".to_string() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);

                            if text_limit.len() > 3 {
                                let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        } else if com == "fa" || com == "/fa" {
                            let prompt = &vec[2].to_string();
                            let prompt_img = &vec[3].to_string();
                            let prompt_img = "'".to_owned() + &prompt_img.to_string() + &"'".to_string();
                            let file = "/.config/atr/scpt/fan_art.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).arg(&prompt_img).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d = "\n".to_owned() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);

                            let link = "https://card.syui.ai/".to_owned() + &"fa";
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);

                            if text_limit.len() > 3 {
                                let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        } else if com == "ph" || com == "/ph" {
                            let prompt = &vec[2].to_string();
                            let prompt_img = &vec[3].to_string();
                            let prompt_img = "'".to_owned() + &prompt_img.to_string() + &"'".to_string();
                            let file = "/.config/atr/scpt/photo.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).arg(&prompt_img).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d = "\n".to_owned() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);

                            let link = "https://card.syui.ai/".to_owned() + &"ph";
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);

                            if text_limit.len() > 3 {
                                let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        } else if com == "user" || com == "/user" {
                            let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/user_list.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let output = Command::new(&f).arg(&handle).arg(&prompt).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d = "\n".to_owned() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);
                            if text_limit.len() > 3 {
                                let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        } else if com == "bot" || com == "/bot" {
                            let prompt = &vec[2..].join(" ");
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);
                            let file = "/.config/atr/scpt/bot_list.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let output = Command::new(&f).arg(&prompt).output().expect("zsh");
                            let d = String::from_utf8_lossy(&output.stdout);
                            let d = "\n".to_owned() + &d.to_string();
                            println!("{}", d);
                            let text_limit = char_c(d);
                            println!("{}", text_limit);
                            if text_limit.len() > 3 {
                                let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                let str_notify = at_notify_read::post_request(time.to_string()).await;
                                println!("{}", str_notify);
                                cid_write(cid.to_string());
                            }
                        } else if { com.contains("タロット") == true || com.contains("ルーン") == true} && cccc_ch == false {
                            //let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/card_tarot.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let d = d.to_string();
                                let text_limit = char_c(d);
                                if text_limit.len() > 3 {
                                    println!("{}", text_limit);
                                    cid_write(cid.to_string());
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                }
                            }
                        } else if { com.contains("占") == true || com.contains("うらない") == true || com.contains("うらなって") == true } && cccc_ch == false {
                            //let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/card_fortune.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let d = d.to_string();
                                let text_limit = char_c(d);
                                if text_limit.len() > 3 {
                                    println!("{}", text_limit);
                                    cid_write(cid.to_string());
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                }
                            }
                        } else if { com.contains("fortune") == true } && cccc_ch == false {
                            //let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/card_fortune_en.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let d = d.to_string();
                                let text_limit = char_c(d);
                                if text_limit.len() > 3 {
                                    println!("{}", text_limit);
                                    cid_write(cid.to_string());
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                }
                            }
                        } else if { com.contains("tarot") == true } && cccc_ch == false {
                            //let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/card_tarot_en.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;

                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let d = d.to_string();
                                let text_limit = char_c(d);
                                if text_limit.len() > 3 {
                                    println!("{}", text_limit);
                                    cid_write(cid.to_string());
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                }
                            }
                        } else if { com == "box" || com == "/box" } && cccc_ch == false {
                            //cid_write(cid.to_string());
                            let prompt = &vec[2..].join(" ");
                            //let str_notify = at_notify_read::post_request(time.to_string()).await;
                            //println!("{}", str_notify);
                            let file = "/.config/atr/scpt/card_box.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);

                                // test reply link
                                let handlev: Vec<&str> = handle.split('.').collect();
                                let handlev = handlev[0].trim().to_string();
                                let link = "https://card.syui.ai/".to_owned() + &handlev;
                                let s = 0;
                                let e = link.chars().count();
                                println!("{}", link);
                                println!("{}", e);

                                let d = "\n".to_owned() + &d.to_string();
                                println!("{}", d);
                                let text_limit = char_c(d);
                                println!("{}", text_limit);
                                if text_limit.len() > 3 {
                                    let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                    cid_write(cid.to_string());
                                }
                            }
                        } else if { com == "card" || com == "/card" } && cccc_ch == false {
                            //cid_write(cid.to_string());
                            let prompt = &vec[2..].join(" ");
                            //let str_notify = at_notify_read::post_request(time.to_string()).await;
                            //println!("{}", str_notify);
                            let file = "/.config/atr/scpt/api_card.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let handlev: Vec<&str> = handle.split('.').collect();
                                let handlev = handlev[0].trim().to_string();
                                let link = "https://card.syui.ai/".to_owned() + &handlev;
                                let s = 0;
                                let e = link.chars().count();
                                println!("{}", link);
                                println!("{}", e);
                                let dd = "\n".to_owned() + &d.to_string();
                                let text_limit = char_c(dd);
                                println!("{}", text_limit);
                                if text_limit.len() > 3 {
                                    if d.contains("handle") == false {
                                        let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                        println!("{}", str_rep);
                                    } else {
                                        let handlev = handle.replace(".", "-").to_string();
                                        let link = "https://card.syui.ai/".to_owned() + &handlev;
                                        let s = 0;
                                        let e = link.chars().count();
                                        let str_rep = at_reply_link::post_request(d.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                        println!("{}", str_rep);
                                    }
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                    cid_write(cid.to_string());
                                }
                            }
                        } else if { com == "gift" || com == "/gift" } && cccc_ch == false {
                            let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/api_gift.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                if vec.len() == 4 {
                                    let option = &vec[2..].join(" ");
                                    let sub_option = &vec[3..].join(" ");
                                    let output = Command::new(&f).arg(&handle).arg(&did).arg(&option).arg(&sub_option).output().expect("zsh");
                                    let d = String::from_utf8_lossy(&output.stdout);
                                    let handlev: Vec<&str> = handle.split('.').collect();
                                    let handlev = handlev[0].trim().to_string();
                                    let link = "https://card.syui.ai/".to_owned() + &handlev;
                                    let s = 0;
                                    let e = link.chars().count();
                                    println!("{}", link);
                                    println!("{}", e);
                                    let dd = "\n".to_owned() + &d.to_string();
                                    let text_limit = char_c(dd);
                                    println!("{}", text_limit);
                                    if text_limit.len() > 3 {
                                        if d.contains("handle") == false {
                                            let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                            println!("{}", str_rep);
                                        } else {
                                            let handlev = handle.replace(".", "-").to_string();
                                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                                            let s = 0;
                                            let e = link.chars().count();
                                            let str_rep = at_reply_link::post_request(d.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                            println!("{}", str_rep);
                                        }
                                        let str_notify = at_notify_read::post_request(time.to_string()).await;
                                        println!("{}", str_notify);
                                        cid_write(cid.to_string());
                                    }
                                } else {
                                    let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).output().expect("zsh");
                                    let d = String::from_utf8_lossy(&output.stdout);
                                    let handlev: Vec<&str> = handle.split('.').collect();
                                    let handlev = handlev[0].trim().to_string();
                                    let link = "https://card.syui.ai/".to_owned() + &handlev;
                                    let s = 0;
                                    let e = link.chars().count();
                                    println!("{}", link);
                                    println!("{}", e);
                                    let dd = "\n".to_owned() + &d.to_string();
                                    let text_limit = char_c(dd);
                                    println!("{}", text_limit);
                                    if text_limit.len() > 3 {
                                        if d.contains("handle") == false {
                                            let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                            println!("{}", str_rep);
                                        } else {
                                            let handlev = handle.replace(".", "-").to_string();
                                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                                            let s = 0;
                                            let e = link.chars().count();
                                            let str_rep = at_reply_link::post_request(d.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                            println!("{}", str_rep);
                                        }
                                        let str_notify = at_notify_read::post_request(time.to_string()).await;
                                        println!("{}", str_notify);
                                        cid_write(cid.to_string());
                                    }
                                }
                            }
                        } else if { com == "fav" || com == "/fav" || com == "/fab" || com == "fab" } && cccc_ch == false {
                            let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/api_fav.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let handlev: Vec<&str> = handle.split('.').collect();
                                let handlev = handlev[0].trim().to_string();
                                let link = "https://card.syui.ai/".to_owned() + &handlev;
                                let s = 0;
                                let e = link.chars().count();
                                println!("{}", link);
                                println!("{}", e);
                                let dd = "\n".to_owned() + &d.to_string();
                                let text_limit = char_c(dd);
                                println!("{}", text_limit);
                                if text_limit.len() > 3 {
                                    let str_rep = at_reply_link::post_request(d.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                    cid_write(cid.to_string());
                                }
                            }
                        } else if { com == "egg" || com == "/egg" } && cccc_ch == false {
                            let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/api_egg.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&prompt).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let handlev: Vec<&str> = handle.split('.').collect();
                                let handlev = handlev[0].trim().to_string();
                                let link = "https://card.syui.ai/".to_owned() + &handlev;
                                let s = 0;
                                let e = link.chars().count();
                                println!("{}", link);
                                println!("{}", e);
                                let dd = "\n".to_owned() + &d.to_string();
                                let text_limit = char_c(dd);
                                println!("{}", text_limit);
                                if text_limit.len() > 3 {
                                    let str_rep = at_reply_link::post_request(d.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                    cid_write(cid.to_string());
                                }
                            }
                        } else if { com == "nyan" || com == "/nyan" } && cccc_ch == false {
                            let prompt = &vec[2..].join(" ");
                            let file = "/.config/atr/scpt/nyancat.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).arg(&prompt).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let dd = "\n".to_owned() + &d.to_string();
                                let text_limit = char_c(dd);
                                println!("{}", text_limit);
                                if text_limit.len() > 3 {
                                    let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                    cid_write(cid.to_string());
                                }
                            }
                        } else if { com == "chara" || com == "/chara" } && cccc_ch == false {
                            let cc_ch = cid_check(cid.to_string());
                            use std::process::Command;
                            let handlev: Vec<&str> = handle.split('.').collect();
                            let handlev = handlev[0].trim().to_string();
                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);
                            if cc_ch == false {
                                cid_write(cid.to_string());
                                let option = &vec[2..].join(" ");
                                let file = "/.config/atr/scpt/api_chara.zsh";
                                let mut f = shellexpand::tilde("~").to_string();
                                f.push_str(&file);
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).arg(&option).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let d = "\n".to_owned() + &d.to_string();
                                println!("{}", d);
                                let text_limit = char_c(d);
                                println!("{}", text_limit);
                                if text_limit.len() > 3 {
                                    let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                }
                            } 
                        } else if { com == "ten" || com == "/ten" } && cccc_ch == false {
                            let cc_ch = cid_check(cid.to_string());
                            use std::process::Command;
                            let handlev: Vec<&str> = handle.split('.').collect();
                            let handlev = handlev[0].trim().to_string();
                            let link = "https://card.syui.ai/".to_owned() + &handlev;
                            let s = 0;
                            let e = link.chars().count();
                            println!("{}", link);
                            println!("{}", e);
                            if cc_ch == false {
                                cid_write(cid.to_string());
                                if vec.len() == 2 {
                                    let file = "/.config/atr/scpt/api_ten_auto.zsh";
                                    let mut f = shellexpand::tilde("~").to_string();
                                    f.push_str(&file);
                                    let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).output().expect("zsh");
                                    let d = String::from_utf8_lossy(&output.stdout);
                                    let d = "\n".to_owned() + &d.to_string();
                                    println!("{}", d);
                                    let text_limit = char_c(d);
                                    println!("{}", text_limit);
                                    if text_limit.len() > 3 {
                                        let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                        println!("{}", str_rep);
                                        let str_notify = at_notify_read::post_request(time.to_string()).await;
                                        println!("{}", str_notify);
                                    }
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                }
                                let option = &vec[2..].join(" ");
                                let sub_option = &vec[3..].join(" ");
                                let file = "/.config/atr/scpt/api_ten.zsh";
                                let mut f = shellexpand::tilde("~").to_string();
                                f.push_str(&file);
                                let output = Command::new(&f).arg(&handle).arg(&did).arg(&cid).arg(&uri).arg(&option).arg(&sub_option).output().expect("zsh");
                                let d = String::from_utf8_lossy(&output.stdout);
                                let d = "\n".to_owned() + &d.to_string();
                                println!("{}", d);
                                let text_limit = char_c(d);
                                println!("{}", text_limit);
                                if text_limit.len() > 3 {
                                    let str_rep = at_reply_link::post_request(text_limit.to_string(), link.to_string(), s, e.try_into().unwrap(), cid.to_string(), uri.to_string()).await;
                                    println!("{}", str_rep);
                                    let str_notify = at_notify_read::post_request(time.to_string()).await;
                                    println!("{}", str_notify);
                                }
                            } 
                        } else if reason == "mention" {
                            let str_notify = at_notify_read::post_request(time.to_string()).await;
                            println!("{}", str_notify);
                            let prompt = &vec[1..].join(" ");
                            println!("prompt:{}", prompt);
                            println!("cid:{}, uri:{}", cid, uri);
                            println!("{}", text);
                            //let model = "text-davinci-003";
                            //let str_openai = openai::post_request(prompt.to_string(),model.to_string()).await;
                            let str_openai = openai_char::post_request(prompt.to_string()).await;
                            println!("{}", str_openai);
                            let text_limit = char_c(str_openai);

                            // save like
                            let file = "/.config/atr/scpt/openai_like.zsh";
                            let mut f = shellexpand::tilde("~").to_string();
                            f.push_str(&file);
                            use std::process::Command;
                            Command::new(&f).arg(&handle).arg(&did).arg(&text_limit).output().expect("zsh");
                            let cc_ch = cid_check(cid.to_string());
                            if cc_ch == false {
                                let str_rep = at_reply::post_request(text_limit.to_string(), cid.to_string(), uri.to_string()).await;
                                println!("{}", str_rep);
                                cid_write(cid.to_string());
                            }
                        }
                    }
                }
            }
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn bot(c: &Context) {
    loop {
        aa().unwrap();
        let mode = c.bool_flag("mode");
        let admin = "syui.ai".to_string();
        if let Ok(limit) = c.int_flag("limit") {
            let l: i32 = limit.try_into().unwrap();
            if let Ok(admin) = c.string_flag("admin") {
                bot_run(c,l,admin, mode);
            } else {
                bot_run(c,l,admin, mode);
            }
        } else {
            bot_run(c,100, admin, mode);
        }
        //thread::sleep(time::Duration::from_secs(15));
    }
}

// atr test
fn test(_c: &Context) {
    let model = "text-davinci-003";
    let lang = "en";
    let time = "2023-03-08T08:37:12.165Z";
    let prompt = "test";
    let cid = "bafyreigdwt5te7atk3oekowlursremi7wt6pw37a4bum2jsjvvrj4uuuzq";
    let uri = "at://did:plc:uqzpqmrjnptsxezjx4xuh2mn/app.bsky.feed.post/3jqnetfduws2a";
    let did = "did:plc:uqzpqmrjnptsxezjx4xuh2mn";
    let link = "https://syui.cf";
    let limit: i32 = 3;
    let s = 0;
    let e = link.chars().count();
    let handle = "syui.cf";
    let mid = "bafyreid27zk7lbis4zw5fz4podbvbs4fc5ivwji3dmrwa6zggnj4bnd57u";
    let itype = "image/jpeg";

    //pub mod openai;
    let h = async {
        println!("{}","openai");
        let str = openai::post_request(prompt.to_string(),model.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod deepl;
    let h = async {
        println!("{}","deepl");
        let str = deepl::post_request(prompt.to_string(),lang.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_notify_read;
    let h = async {
        println!("{}","at_notify_read");
        let str = at_notify_read::post_request(time.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_reply;
    let h = async {
        println!("{}","at_reply");
        let str = at_reply::post_request(prompt.to_string(), cid.to_string(), uri.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_reply_media;
    let h = async {
        println!("{}","at_reply_media");
        let str = at_reply_media::post_request(prompt.to_string(), cid.to_string(), uri.to_string(), mid.to_string(), itype.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_notify_limit;
    let h = async {
        println!("{}","at_notify_limit");
        let str = at_notify_limit::get_request(limit);
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_post;
    let h = async {
        println!("{}","at_post");
        let str = at_post::post_request(prompt.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_post_link;
    let h = async {
        println!("{}","at_post_link");
        let str = at_post_link::post_request(prompt.to_string(), link.to_string(), s, e.try_into().unwrap());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_profile;
    let h = async {
        println!("{}","at_profile");
        let str = at_profile::get_request(handle.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_mention;
    let h = async {
        let at = "@".to_owned() + &handle;
        let e = at.chars().count();
        let udid = did;
        println!("{}","at_mention");
        let str = at_mention::post_request(prompt.to_string(), at.to_string(), udid.to_string(), s, e.try_into().unwrap());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_timeline;
    let h = async {
        println!("{}","at_timeline");
        let str = at_timeline::get_request();
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);

    //pub mod at_handle_update;
    let h = async {
        println!("{}","at_handle_update");
        let str = at_handle_update::post_request(handle.to_string());
        println!("{}",str.await);
    };
    tokio::runtime::Runtime::new().unwrap().block_on(h);
}



