extern crate rustc_serialize;
pub mod data;
use std::env;
use std::path::Path;
use seahorse::{App, Command, Context, Flag, FlagType};
use std::fs;
use std::collections::HashMap;
use rustc_serialize::json::Json;
use std::fs::File;
use std::io::Read;
use serde_json::{json};
use smol_str::SmolStr; // stack-allocation for small strings
use iso8601_timestamp::Timestamp;

use data::Data as Datas;
use data::Notify as Notify;
use data::Token as Token;
use data::Did as Did;
use data::Cid as Cid;
use data::Handle as Handle;
use data::Deep as Deeps;
use data::Open as Opens;
use crate::data::Timeline;
use crate::data::url;
use crate::data::token_file;
use crate::data::token_toml;
use crate::data::Tokens;

use std::io;
use std::io::Write;

use reqwest::header::AUTHORIZATION;
use reqwest::header::CONTENT_TYPE;
use serde::{Deserialize, Serialize};

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

fn main() {
    let args: Vec<String> = env::args().collect(); let app = App::new(env!("CARGO_PKG_NAME"))
        .author(env!("CARGO_PKG_AUTHORS"))
        .description(env!("CARGO_PKG_DESCRIPTION"))
        .version(env!("CARGO_PKG_VERSION"))
        .usage("atr [option] [x]\n\t~/.config/atr/config.toml\n\t\thost = 'bsky.social'\n\t\tuser = 'syui.bsky.social'\n\t\tpass = 'xxx'")
        .command(
            Command::new("start")
            .usage("atr start")
            .description("start first\n\t\t\t$ atr start\n\t\t\t$ atr start -u syui.bsky.social -p $password")
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
            Command::new("swich")
            .usage("msr swich {}")
            .description("account switch\n\t\t\t$ atr ss -d(setting.toml)\n\t\t\t$ atr ss -s(social.toml)")
            .alias("ss")
            .action(account_switch),
            )
        .command(
            Command::new("create")
            .usage("atr create")
            .description("create account\n\t\t\t$ atr c -i invite-code -e email")
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
                    Flag::new("latest", FlagType::Bool)
                    .description("latest flag\n\t\t\t$ atr t -l")
                    .alias("l"),
                    )
                .flag(
                    Flag::new("json", FlagType::Bool)
                    .description("count flag\n\t\t\t$ atr t -j")
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
                Command::new("profile")
                .usage("atr profile")
                .description("profile\n\t\t\t$ atr profile")
                .alias("pro")
                .action(profile),
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
                    Flag::new("count", FlagType::Int)
                    .description("count flag\n\t\t\t$ atr n -c 0")
                    .alias("c"),
                    )
                )
            .command(
                Command::new("deepl")
                .usage("atr tt {}")
                .description("translate message, ex: $ atr tt $text -l en")
                .alias("tt")
                .action(deepl_post)
                .flag(
                    Flag::new("lang", FlagType::String)
                    .description("Lang flag")
                    .alias("l"),
                    )
                )
            .command(
                Command::new("deepl-api")
                .usage("atr deepl-api {}")
                .description("deepl-api change, ex : $ atr deepl-api $api")
                .action(deepl_api),
                )
            .command(
                Command::new("openai")
                .usage("atr chatgpt {}")
                .description("translate message, ex: $ atr tt $text -l en")
                .alias("chat")
                .action(openai_post)
                .flag(
                    Flag::new("model", FlagType::String)
                    .description("model flag")
                    .alias("m"),
                    )
                .flag(
                    Flag::new("chat-ja", FlagType::Bool)
                    .description("chatgpt japanese mode flag")
                    )
                )
            .command(
                Command::new("openai-api")
                .usage("atr openai-api {}")
                .description("openai-api change, ex : $ atr openai-api $api")
                .action(openai_api),
                )
            .command(
                Command::new("bot")
                .usage("atr bot {}")
                .description("bot message")
                .alias("b")
                .action(bot)
                .flag(
                    Flag::new("chat", FlagType::Bool)
                    .description("bot-chat flag")
                    .alias("c"),
                    )
                .flag(
                    Flag::new("deepl", FlagType::Bool)
                    .description("bot-deepl flag")
                    .alias("d"),
                    )
                .flag(
                    Flag::new("lang", FlagType::String)
                    .description("bot-chat flag")
                    .alias("l"),
                    )
                )
            ;
    app.run(args);
}

#[tokio::main]
async fn at_user(url: String,user :String) -> reqwest::Result<()> {
    let client = reqwest::Client::new();
    let body = client.get(url)
        .query(&[("user", &user)])
        .send()
        .await?
        .text()
        .await?;
    println!("{}", body);
    Ok(())
}

#[allow(unused_must_use)]
fn ss(c :&Context) -> reqwest::Result<()> {
    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let url = url(&"describe");
    if let Ok(user) = c.string_flag("user") {
        at_user(url, user);
    } else {
        let user = data.user;
        at_user(url, user);
    }
    Ok(())
}

fn s(c: &Context) {
    ss(c).unwrap();
}

#[tokio::main]
async fn at_feed(url: String, user: String, col: String) -> reqwest::Result<()> {
    let client = reqwest::Client::new();
    let body = client.get(url)
        .query(&[("user", &user),("collection", &col)])
        .send()
        .await?
        .text()
        .await?;
    println!("{}", body);
    Ok(())
}

#[allow(unused_must_use)]
fn ff(c :&Context) -> reqwest::Result<()> {
    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let url = url(&"record_list");
    let col = "app.bsky.feed.post".to_string();
    if let Ok(user) = c.string_flag("user") {
        at_feed(url, user, col);
    } else {
        let user = data.user;
        at_feed(url, user, col);
    }
    Ok(())
}

fn f(c: &Context) {
    ff(c).unwrap();
}

#[tokio::main]
async fn aa() -> reqwest::Result<()> {
    let f = token_file(&"json");

    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };

    let handle = data.user;
    let mut map = HashMap::new();

    let url = url(&"session_create");
    map.insert("handle", &handle);
    map.insert("password", &data.pass);
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

fn a(_c: &Context) {
    aa().unwrap();
}

#[tokio::main]
async fn pp(c: &Context) -> reqwest::Result<()> {
   
    let token = token_toml(&"access");
    let did = token_toml(&"did");
    
    let url = url(&"record_create");
    let col = "app.bsky.feed.post".to_string();
    let d = Timestamp::now_utc();
    let d = d.to_string();

    let m = c.args[0].to_string();

    if let Ok(link) = c.string_flag("link") {
        let e = link.chars().count();
        let s = 0;
        let post = Some(json!({
            "did": did.to_string(),
            "collection": col.to_string(),
            "record": {
                "text": link.to_string() + &" ".to_string() + &m.to_string(),
                "createdAt": d.to_string(),
                "entities": [
                {
                    "type": "link".to_string(),
                    "index": {
                        "end": e,
                        "start": s
                    },
                    "value": link.to_string()
                }
                ]
            },
        }));

        let client = reqwest::Client::new();
        let res = client
            .post(url)
            .json(&post)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;

        println!("{}", res);

    } else {
        let post = Some(json!({
            "did": did.to_string(),
            "collection": col.to_string(),
            "record": {
                "text": m.to_string(),
                "createdAt": d.to_string(),
            },
        }));

        let client = reqwest::Client::new();
        let res = client
            .post(url)
            .json(&post)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;

        println!("{}", res);
    }
    Ok(())
}

#[tokio::main]
async fn tt(c: &Context) -> reqwest::Result<()> {
    let token = token_toml(&"access");
    //let did = token_toml(&"did");

    let url = url(&"timeline_get");

    let client = reqwest::Client::new();
    let j = client.get(url)
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await?
        .text()
        .await?;

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
            println!("⚡️ [{}]\t🌈 [{}]\t⭐️ [{}]", n[i].post.replyCount,n[i].post.replyCount, n[i].post.upvoteCount);
            println!("{}", "---------");
        }
    }

    Ok(())
}

fn t(c: &Context) {
    aa().unwrap();
    tt(c).unwrap();
}

#[tokio::main]
async fn pro(c: &Context) -> reqwest::Result<()> {

    let token = token_toml(&"access");

    if c.args[0].is_empty() == false {
        let user = c.args[0].to_string();
        let url = url(&"profile_get") + &"?actor=" + &user;
        println!("{}", url);
        let client = reqwest::Client::new();
        let j = client.get(url)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;
        let file = "/.config/atr/".to_owned() + &user.to_string() + &".json".to_string();
        let mut f = shellexpand::tilde("~").to_string();
        f.push_str(&file);
        let mut f = fs::File::create(f).unwrap();
        if j != "" {
            f.write_all(&j.as_bytes()).unwrap();
        }
        println!("{}", j);
    }
    Ok(())
}

fn profile(c: &Context) {
    aa().unwrap();
    pro(c).unwrap();
}

#[tokio::main]
async fn mm(c: &Context) -> reqwest::Result<()> {
    
    let token = token_toml(&"access");

    let atoken = "Authorization: Bearer ".to_owned() + &token;
    let con = "Content-Type: image/png";
    let did = token_toml(&"did");

    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };

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
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.repo.createRecord";
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
async fn hh(c: &Context) -> reqwest::Result<()> {
    
    let token = token_toml(&"access");
    let did = token_toml(&"did");
    
    let m = c.args[0].to_string();

    let url = url(&"update_handle");
    println!("DNS txt : _atproto.{}, did={}.", m, did);

    let handle = Handle {
        handle: m.to_string()
    };
 
    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .json(&handle)
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await?
        .text()
        .await?;

    println!("{}", res);
    Ok(())
}

fn h(c: &Context) {
    aa().unwrap();
    hh(c).unwrap();
}

#[tokio::main]
async fn cc(c: &Context) -> reqwest::Result<()> {
    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };

    let url = url(&"account_create");
    let handle = data.user;

    let mut map = HashMap::new();
    map.insert("handle", &handle);
    map.insert("password", &data.pass);
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

#[tokio::main]
async fn mention(c: &Context) -> reqwest::Result<()> {

    let token = token_toml(&"access");
    let did = token_toml(&"did");

    let m = c.args[0].to_string();

    let file = "/.config/atr/".to_owned() + &m.to_string() + &".json".to_string();
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    let mut file = File::open(f).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();

    let udid: Did = serde_json::from_str(&data).unwrap();
    let udid = udid.did;
    let handle: Handle = serde_json::from_str(&data).unwrap();
    let handle = handle.handle;

    let url = url(&"record_create");
    let col = "app.bsky.feed.post".to_string();

    let d = Timestamp::now_utc();
    let d = d.to_string();

    let at = "@".to_owned() + &handle;
    let e = at.chars().count();
    let s = 0;
    if let Ok(post) = c.string_flag("post") {
        let p = Some(json!({
            "did": did.to_string(),
            "collection": col.to_string(),
            "record": {
                "text": at.to_string() + &" ".to_string() + &post.to_string(),
                "createdAt": d.to_string(),
                "entities": [
                {
                    "type": "mention".to_string(),
                    "index": {
                        "end": e,
                        "start": s
                    },
                    "value": udid.to_string()
                }
                ]
            },
        }));
        let client = reqwest::Client::new();
        let res = client
            .post(url)
            .json(&p)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;
        println!("{}", res);
    } else {
        let post = Some(json!({
            "did": did.to_string(),
            "collection": col.to_string(),
            "record": {
                "text": m.to_string(),
                "createdAt": d.to_string(),
                "entities": [
                {
                    "type": "mention".to_string(),
                    "index": {
                        "end": e,
                        "start": s
                    },
                    "value": udid.to_string()
                }
                ]
            },
        }));
        let client = reqwest::Client::new();
        let res = client
            .post(url)
            .json(&post)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;
        println!("{}", res);
    }
    Ok(())
}

fn mention_run(c: &Context) {
    aa().unwrap();
    pro(c).unwrap();
    mention(c).unwrap();
}

#[tokio::main]
async fn nn(c: &Context) -> reqwest::Result<()> {

    let token = token_toml(&"access");
    //let did = token_toml(&"did");

    if let Ok(_get) = c.string_flag("get") {

        let url = url(&"notify_count");
        let client = reqwest::Client::new();
        let res = client
            .get(url)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;
        println!("{}", res);
    } 

    let url = url(&"notify_list");
    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await?
        .text()
        .await?;
    let notify: Notify = serde_json::from_str(&res).unwrap();
    let n = notify.notifications;
    let mut map = HashMap::new();

    if c.bool_flag("latest") {
        map.insert("handle", &n[0].author.handle);
        map.insert("createdAt", &n[0].record.createdAt);
        map.insert("uri", &n[0].uri);
        map.insert("cid", &n[0].cid);
        map.insert("reason", &n[0].reason);
        if ! n[0].record.text.is_none() { 
            map.insert("text", &n[0].record.text.as_ref().unwrap());
        } 
        println!("{:?}", map);
    } else if let Ok(count) = c.int_flag("count") {
        let length = &n.len();
        for i in 0..*length {
            if i < count.try_into().unwrap() {
                println!("handle : {}", n[i].author.handle);
                println!("createdAt : {}", n[i].record.createdAt);
                println!("uri : {}", n[i].uri);
                println!("cid : {}", n[i].cid);
                if ! n[i].record.text.is_none() { 
                    println!("text : {}", n[i].record.text.as_ref().unwrap());
                }
                println!("{}", "---------");
            }
        }
    } else {
        println!("{}", res);
    }
    Ok(())
}

fn n(c: &Context) {
    aa().unwrap();
    nn(c).unwrap();
}

fn get_domain_zsh() {
    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let e = "export BLUESKY_BASE=".to_owned() + &data.user.to_string() + "\n";
    //let e = "export BLUESKY_BASE=".to_owned() + &data.user.to_string() + &".".to_string() + &data.host.to_string() + "\n";
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
    println!("{}", f);

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

#[tokio::main]
async fn rr(c: &Context) -> reqwest::Result<()> {

    let token = token_toml(&"access");
    let did = token_toml(&"did");
    
    let url = url(&"record_create");
    let col = "app.bsky.feed.post".to_string();
    let d = Timestamp::now_utc();
    let d = d.to_string();

    let m = c.args[0].to_string();
    if let Ok(link) = c.string_flag("link") {
        let e = link.chars().count();
        let s = 0;
        let post = Some(json!({
            "did": did.to_string(),
            "collection": col.to_string(),
            "record": {
                "text": link.to_string() + &" ".to_string() + &m.to_string(),
                "createdAt": d.to_string(),
                "entities": [
                {
                    "type": "link".to_string(),
                    "index": {
                        "end": e,
                        "start": s
                    },
                    "value": link.to_string()
                }
                ]
            },
        }));

        let client = reqwest::Client::new();
        let res = client
            .post(url)
            .json(&post)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;

        println!("{}", res);

    } else {
        if let Ok(uri) = c.string_flag("uri") {
            if let Ok(cid) = c.string_flag("cid") {
                let post = Some(json!({
                    "did": did.to_string(),
                    "collection": col.to_string(),
                    "record": {
                        "text": m.to_string(),
                        "createdAt": d.to_string(),
                        "reply": {
                            "root": {
                                "cid": cid.to_string(),
                                "uri": uri.to_string()
                            },
                            "parent": {
                                "cid": cid.to_string(),
                                "uri": uri.to_string()
                            }
                        }
                    },
                }));

                let client = reqwest::Client::new();
                let res = client
                    .post(url)
                    .json(&post)
                    .header("Authorization", "Bearer ".to_owned() + &token)
                    .send()
                    .await?
                    .text()
                    .await?;

                println!("{}", res);
            }
        }
    }
    Ok(())
}

fn r(c: &Context) {
    aa().unwrap();
    rr(c).unwrap();
}

#[tokio::main]
async fn deepl(message: String,lang: String) -> reqwest::Result<()> {
    let data = Deeps::new().unwrap();
    let data = Deeps {
        api: data.api,
    };
    let api = "DeepL-Auth-Key ".to_owned() + &data.api;
    let mut params = HashMap::new();
    params.insert("text", &message);
    params.insert("target_lang", &lang);
    let client = reqwest::Client::new();
    let res = client
        .post("https://api-free.deepl.com/v2/translate")
        .header(AUTHORIZATION, api)
        .header(CONTENT_TYPE, "json")
        .form(&params)
        .send()
        .await?
        .text()
        .await?;
    let p: DeepData = serde_json::from_str(&res).unwrap();
    let o = &p.translations[0].text;
    //println!("{}", res);
    println!("{}", o);
    Ok(())
}

#[allow(unused_must_use)]
fn deepl_post(c: &Context) {
    let m = c.args[0].to_string();
    if let Ok(lang) = c.string_flag("lang") {
        deepl(m,lang.to_string());
    } else {
        let lang = "ja";
        deepl(m,lang.to_string());
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

#[tokio::main]
async fn ppd(c: &Context, lang: &str) -> reqwest::Result<()> {
    let m = c.args[0].to_string();
    let lang = lang.to_string();

    let data = Deeps::new().unwrap();
    let data = Deeps {
        api: data.api,
    };
    let api = "DeepL-Auth-Key ".to_owned() + &data.api;
    let mut params = HashMap::new();
    params.insert("text", &m);
    params.insert("target_lang", &lang);
    let client = reqwest::Client::new();
    let res = client
        .post("https://api-free.deepl.com/v2/translate")
        .header(AUTHORIZATION, api)
        .header(CONTENT_TYPE, "json")
        .form(&params)
        .send()
        .await?
        .text()
        .await?;

    let p: DeepData = serde_json::from_str(&res).unwrap();
    let o = &p.translations[0].text;
    println!("deepl : {}", o);
   
    let token = token_toml(&"access");
    let did = token_toml(&"did");
    
    let url = url(&"record_create");
    let col = "app.bsky.feed.post".to_string();
    let d = Timestamp::now_utc();
    let d = d.to_string();

    if let Ok(uri) = c.string_flag("uri") {
        if let Ok(cid) = c.string_flag("cid") {
            let post = Some(json!({
                "did": did.to_string(),
                "collection": col.to_string(),
                "record": {
                    "text": o.to_string(),
                    "createdAt": d.to_string(),
                    "reply": {
                        "root": {
                            "cid": cid.to_string(),
                            "uri": uri.to_string()
                        },
                        "parent": {
                            "cid": cid.to_string(),
                            "uri": uri.to_string()
                        }
                    }
                },
            }));

            let client = reqwest::Client::new();
            let res = client
                .post(url)
                .json(&post)
                .header("Authorization", "Bearer ".to_owned() + &token)
                .send()
                .await?
                .text()
                .await?;

            println!("{}", res);
        }
    } else {
        let post = Some(json!({
            "did": did.to_string(),
            "collection": col.to_string(),
            "record": {
                "text": o.to_string(),
                "createdAt": d.to_string(),
            },
        }));

        let client = reqwest::Client::new();
        let res = client
            .post(url)
            .json(&post)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;

        println!("{}", res);
    }
    Ok(())
}

#[tokio::main]
async fn openai(c: &Context, prompt: String, model: String) -> reqwest::Result<()> {
    let data = Opens::new().unwrap();
    let data = Opens {
        api: data.api,
    };
    let temperature = 0.7;
    let max_tokens = 250;
    let top_p = 1;
    let frequency_penalty = 0;
    let presence_penalty = 0;
    let stop = "[\"###\"]";

    let post = Some(json!({
        "prompt": &prompt.to_string(),
        "model": &model.to_string(),
        "temperature": temperature,
        "max_tokens": max_tokens,
        "top_p": top_p,
        "frequency_penalty": frequency_penalty,
        "presence_penalty": presence_penalty,
        "stop": stop,
    }));
        
    let client = reqwest::Client::new();
    let res = client
        .post("https://api.openai.com/v1/completions")
        .header("Authorization", "Bearer ".to_owned() + &data.api)
        .json(&post)
        .send()
        .await?
        .text()
        .await?;
    let p: OpenData = serde_json::from_str(&res).unwrap();
    let o = &p.choices[0].text;
    if c.bool_flag("chat-ja") {
        let o: String = o.chars().filter(|c| !c.is_whitespace()).collect();
        println!("chatgpt : {}", o);
    } else {
        println!("chatgpt : {}", o);
    }
    Ok(())
}

#[allow(unused_must_use)]
fn openai_post(c: &Context) {
    let m = c.args[0].to_string();
    if let Ok(model) = c.string_flag("model") {
        openai(c, m, model.to_string());
    } else {
        let model = "text-davinci-003";
        openai(c, m, model.to_string());
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

#[tokio::main]
async fn ppc(c: &Context, model: &str) -> reqwest::Result<()> {
    let m = c.args[0].to_string();
    let model = model.to_string();

    let data = Opens::new().unwrap();
    let data = Opens {
        api: data.api,
    };

    let temperature = 0.7;
    let max_tokens = 250;
    let top_p = 1;
    let frequency_penalty = 0;
    let presence_penalty = 0;
    let stop = "[\"###\"]";

    let post = Some(json!({
        "prompt": &m.to_string(),
        "model": &model.to_string(),
        "temperature": temperature,
        "max_tokens": max_tokens,
        "top_p": top_p,
        "frequency_penalty": frequency_penalty,
        "presence_penalty": presence_penalty,
        "stop": stop,
    }));

    let client = reqwest::Client::new();
    let res = client
        .post("https://api.openai.com/v1/completions")
        .header("Authorization", "Bearer ".to_owned() + &data.api)
        .json(&post)
        .send()
        .await?
        .text()
        .await?;
    let p: OpenData = serde_json::from_str(&res).unwrap();
    let o = &p.choices[0].text;
    if c.bool_flag("chat-ja") {
        let o: String = o.chars().filter(|c| !c.is_whitespace()).collect();
        println!("chatgpt : {}", o);
    } else {
        println!("chatgpt : {}", o);
    }
   
    let token = token_toml(&"access");
    let did = token_toml(&"did");
    
    let url = url(&"record_create");
    let col = "app.bsky.feed.post".to_string();
    let d = Timestamp::now_utc();
    let d = d.to_string();

    if let Ok(uri) = c.string_flag("uri") {
        if let Ok(cid) = c.string_flag("cid") {
            let post = Some(json!({
                "did": did.to_string(),
                "collection": col.to_string(),
                "record": {
                    "text": o.to_string(),
                    "createdAt": d.to_string(),
                    "reply": {
                        "root": {
                            "cid": cid.to_string(),
                            "uri": uri.to_string()
                        },
                        "parent": {
                            "cid": cid.to_string(),
                            "uri": uri.to_string()
                        }
                    }
                },
            }));

            let client = reqwest::Client::new();
            let res = client
                .post(url)
                .json(&post)
                .header("Authorization", "Bearer ".to_owned() + &token)
                .send()
                .await?
                .text()
                .await?;

            println!("{}", res);
        }
    } else {
        let post = Some(json!({
            "did": did.to_string(),
            "collection": col.to_string(),
            "record": {
                "text": o.to_string(),
                "createdAt": d.to_string(),
            },
        }));

        let client = reqwest::Client::new();
        let res = client
            .post(url)
            .json(&post)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;

        println!("{}", res);
    }
    Ok(())
}

fn p(c: &Context) {
    aa().unwrap();
    if c.bool_flag("en") {
        ppd(c, &"en").unwrap();
    } else if c.bool_flag("ja") {
        ppd(c, &"ja").unwrap();
    } else if c.bool_flag("chat") {
        ppc(c, &"text-davinci-003").unwrap();
    } else {
        pp(c).unwrap();
    }
}

#[allow(unused_must_use)]
#[tokio::main]
async fn bot_notify_openai(_c: &Context) -> reqwest::Result<()> {
    let token = token_toml(&"access");
    let url = url(&"notify_list");
    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("limit", 4)])
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await?
        .text()
        .await?;
    let notify: Notify = serde_json::from_str(&res).unwrap();
    let n = notify.notifications;

    let length = &n.len();
    for i in 0..*length {
        let reason = &n[i].reason;
        let handle = &n[i].author.handle;
        let read = n[i].isRead;
        //if reason == "mention" &&  handle == "syui.cf" && read == false {
        //    println!("{}", read);
        //}
        if reason == "mention" &&  handle == "syui.cf" && read == false {
            let time = &n[i].record.createdAt;
            let cid = &n[i].cid;
            let uri = &n[i].uri;
            if ! n[i].record.text.is_none() { 
                let text = &n[i].record.text.as_ref().unwrap();
                let vec: Vec<&str> = text.split_whitespace().collect();
                if vec.len() > 2 {
                    let com = vec[1].trim().to_string();
                    let prompt = &vec[2..].join(" ");
                    println!("cmd:{}, prompt:{}", com, prompt);
                    println!("cid:{}, uri:{}", cid, uri);
                    if com == "/chat" {
                        println!("{}", text);
                        let model = "text-davinci-003";
                        let data = Opens::new().unwrap();
                        let data = Opens {
                            api: data.api,
                        };
                        let temperature = 0.7;
                        let max_tokens = 250;
                        let top_p = 1;
                        let frequency_penalty = 0;
                        let presence_penalty = 0;
                        let stop = "[\"###\"]";

                        let post = Some(json!({
                            "prompt": &prompt.to_string(),
                            "model": &model.to_string(),
                            "temperature": temperature,
                            "max_tokens": max_tokens,
                            "top_p": top_p,
                            "frequency_penalty": frequency_penalty,
                            "presence_penalty": presence_penalty,
                            "stop": stop,
                        }));

                        let client = reqwest::Client::new();
                        let res = client
                            .post("https://api.openai.com/v1/completions")
                            .header("Authorization", "Bearer ".to_owned() + &data.api)
                            .json(&post)
                            .send()
                            .await?
                            .text()
                            .await?;
                        let p: OpenData = serde_json::from_str(&res).unwrap();
                        let o = &p.choices[0].text;
                        let o = o.replace("\n", "");
                        println!("chatgpt : {}", o);

                        let token = token_toml(&"access");
                        let did = token_toml(&"did");

                        //let at_url = url(&"record_create");
                        let at_url = "https://bsky.social/xrpc/com.atproto.repo.createRecord";
                        let col = "app.bsky.feed.post".to_string();
                        let d = Timestamp::now_utc();
                        let d = d.to_string();

                        let post = Some(json!({
                            "did": did.to_string(),
                            "collection": col.to_string(),
                            "record": {
                                "text": o.to_string(),
                                "createdAt": d.to_string(),
                                "reply": {
                                    "root": {
                                        "cid": cid.to_string(),
                                        "uri": uri.to_string()
                                    },
                                    "parent": {
                                        "cid": cid.to_string(),
                                        "uri": uri.to_string()
                                    }
                                }
                            },
                        }));

                        let client = reqwest::Client::new();
                        let res = client
                            .post(at_url)
                            .json(&post)
                            .header("Authorization", "Bearer ".to_owned() + &token)
                            .send()
                            .await?
                            .text()
                            .await?;

                        println!("{}", res);

                        let at_url = "https://bsky.social/xrpc/app.bsky.notification.updateSeen";
                        let post = Some(json!({
                            "seenAt": time.to_string(),
                        }));

                        let client = reqwest::Client::new();
                        let res = client
                            .post(at_url)
                            .json(&post)
                            .header("Authorization", "Bearer ".to_owned() + &token)
                            .send()
                            .await?
                            .text()
                            .await?;

                        println!("{}", res);
                    }
                }
            }
        }
    }
    Ok(())
}

fn bot(c: &Context) {
    aa().unwrap();
    if c.bool_flag("chat") {
        bot_notify_openai(c).unwrap();
    }
    //if c.bool_flag("deepl") {
    //    bot_notify_deepl(c)).unwrap();
    //}
}
