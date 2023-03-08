extern crate rustc_serialize;
pub mod data;
use std::env;
use data::Data as Datas;
use seahorse::{App, Command, Context, Flag, FlagType};
use std::fs;
use std::io::Write;
use std::collections::HashMap;
use rustc_serialize::json::Json;
use std::fs::File;
use std::io::Read;
use serde::{Deserialize, Serialize};
use serde_json::{json};
fn main() {
    let args: Vec<String> = env::args().collect(); let app = App::new(env!("CARGO_PKG_NAME"))
        .author(env!("CARGO_PKG_AUTHORS"))
        .description(env!("CARGO_PKG_DESCRIPTION"))
        .version(env!("CARGO_PKG_VERSION"))
        .usage("atr [option] [x]")
        .command(
            Command::new("auth")
            .usage("atr a")
            .description("auth")
            .alias("a")
            .action(a),
            )
        .command(
            Command::new("create")
            .usage("atr create")
            .description("account create(ex: $ atr c -i invite-code)")
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
            .description("status")
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
            .description("custom handle")
            .alias("h")
            .action(h)
            )
        .command(
            Command::new("feed")
            .usage("atr f")
            .description("feed")
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
            .description("post")
            .alias("p")
            .action(p)
            .flag(
                Flag::new("link", FlagType::String)
                .description("link flag(ex: $ atr p -l)")
                .alias("l"),
                )
            )
        .command(
            Command::new("postlink")
            .usage("atr pl {}")
            .description("postlink")
            .alias("pl")
            .action(p_link),
            )
        .command(
            Command::new("timeline")
            .usage("atr t")
            .description("user timeline")
            .alias("t")
            .action(t),
            )
        .command(
            Command::new("media")
            .usage("atr m {} -p text")
            .description("media post")
            .alias("m")
            .action(m)
            )
        .command(
            Command::new("profile")
            .usage("atr profile")
            .description("profile")
            .action(profile)
            .flag(
                Flag::new("user", FlagType::String)
                .description("user flag(ex: $ atr profile -u user)")
                .alias("u"),
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
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.repo.describe";
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
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.repo.listRecords";
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
    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.session.create";
    let handle = data.user;
    //let handle = data.user + &"." + &data.host;

    let mut map = HashMap::new();
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

    let file = "/.config/atr/token.json";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    let mut f = fs::File::create(f).unwrap();
    if j != "" {
        f.write_all(&j.as_bytes()).unwrap();
    }
    Ok(())
}

fn a(_c: &Context) {
    aa().unwrap();
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
struct Token {
    did: String,
    accessJwt: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
struct Record {
    text: String,
    createdAt: String,
}

#[derive(Serialize, Deserialize)]
struct Post {
    did: String,
    collection: String,
    record: Record
}

#[derive(Serialize, Deserialize)]
struct Cid {
    cid: String
}

#[derive(Serialize, Deserialize)]
struct Handle {
    handle: String
}

#[tokio::main]
async fn pp(c: &Context) -> reqwest::Result<()> {
    let file = "/.config/atr/token.json";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    let mut file = File::open(f).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();

    let json: Token = serde_json::from_str(&data).unwrap();
    let token = json.accessJwt;
    let did = json.did;
    

    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.repo.createRecord";
    let col = "app.bsky.feed.post".to_string();
    use std::process::Command;
    let output = Command::new("date").arg("-u").arg("+'%Y-%m-%dT%H:%M:%SZ'").output().expect("sh");
    let d = String::from_utf8_lossy(&output.stdout);
    let d =  d.to_string();
    let d: String = d.replace("'", "").replace("\n", "");

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
        let d: String = d.replace("'", "").replace("\n", "");
        let post = Post {
            did: did.to_string(),
            collection: col.to_string(),
            record: Record {
                text: m.to_string(),
                createdAt: d.to_string(),
            }
        };

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
    pp(c).unwrap();
}

#[tokio::main]
async fn tt(_c: &Context) -> reqwest::Result<()> {
    let file = "/.config/atr/token.json";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    let mut file = File::open(f).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();

    let json: Token = serde_json::from_str(&data).unwrap();
    let token = json.accessJwt;

    let url = "https://bsky.social/xrpc/app.bsky.feed.getTimeline";

    let client = reqwest::Client::new();
    let j = client.get(url)
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await?
        .text()
        .await?;

    println!("{}", j);
    Ok(())
}

fn t(_c: &Context) {
    aa().unwrap();
    tt(_c).unwrap();
}

#[tokio::main]
async fn pro(c: &Context) -> reqwest::Result<()> {
    let file = "/.config/atr/token.json";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    let mut file = File::open(f).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();

    let json: Token = serde_json::from_str(&data).unwrap();
    let token = json.accessJwt;

    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };

    if let Ok(user) = c.string_flag("user") {
        let url = "https://bsky.social/xrpc/app.bsky.actor.getProfile?actor=".to_owned() + &user;
        let client = reqwest::Client::new();
        let j = client.get(url)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;
        println!("{:#?}", j);
    } else {
        let url = "https://bsky.social/xrpc/app.bsky.actor.getProfile?actor=".to_owned() + &data.user;
        let client = reqwest::Client::new();
        let j = client.get(url)
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await?
            .text()
            .await?;
        println!("{:#?}", j);
    }
    Ok(())
}

fn profile(c: &Context) {
    aa().unwrap();
    pro(c).unwrap();
}

#[tokio::main]
async fn mm(c: &Context) -> reqwest::Result<()> {
    let file = "/.config/atr/token.json";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);
    let mut file = File::open(f).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();
    let json: Token = serde_json::from_str(&data).unwrap();
    let token = json.accessJwt;
    let atoken = "Authorization: Bearer ".to_owned() + &token;
    let con = "Content-Type: image/png";
    let did = json.did;

    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.blob.upload";

    let f = "@".to_owned() + &c.args[0].to_string();
    use std::process::Command;
    let output = Command::new("curl").arg("-X").arg("POST").arg("-sL").arg("-H").arg(&con).arg("-H").arg(&atoken).arg("--data-binary").arg(&f).arg(&url).output().expect("curl");
    let d = String::from_utf8_lossy(&output.stdout);
    let d =  d.to_string();
    let cid: Cid = serde_json::from_str(&d).unwrap();

    let output = Command::new("date").arg("-u").arg("+'%Y-%m-%dT%H:%M:%SZ'").output().expect("sh");
    let d = String::from_utf8_lossy(&output.stdout);
    let d =  d.to_string();
    let d: String = d.replace("'", "").replace("\n", "");
    println!("{}", d);
    let mtype = "image/png".to_string();
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
    let file = "/.config/atr/token.json";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    let mut file = File::open(f).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();

    let json: Token = serde_json::from_str(&data).unwrap();
    let token = json.accessJwt;
    let did = json.did;
    
    let m = c.args[0].to_string();

    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.handle.update";
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
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.account.create";
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
async fn pp_link(c: &Context) -> reqwest::Result<()> {
    let file = "/.config/atr/token.json";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    let mut file = File::open(f).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();

    let json: Token = serde_json::from_str(&data).unwrap();
    let token = json.accessJwt;
    let did = json.did;
    
    let m = c.args[0].to_string();

    let data = Datas::new().unwrap();
    let data = Datas {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let url = "https://".to_owned() + &data.host + &"/xrpc/com.atproto.repo.createRecord";
    let col = "app.bsky.feed.post".to_string();
    use std::process::Command;
    let output = Command::new("date").arg("-u").arg("+'%Y-%m-%dT%H:%M:%SZ'").output().expect("sh");
    let d = String::from_utf8_lossy(&output.stdout);
    let d =  d.to_string();
    let d: String = d.replace("'", "").replace("\n", "");

    let e = m.chars().count();
    let s = 0;
    let post = Some(json!({
        "did": did.to_string(),
        "collection": col.to_string(),
        "record": {
            "text": m.to_string(),
            "createdAt": d.to_string(),
            "entities": [
            {
                "type": "link".to_string(),
                "index": {
                    "end": e,
                    "start": s
                },
                "value": m.to_string()
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
    Ok(())
}

fn p_link(c: &Context) {
    aa().unwrap();
    pp_link(c).unwrap();
}
