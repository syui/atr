
use seahorse::{App, Command, Context, Flag, FlagType};
use std::env;

use crate::data::data_toml;
use crate::data::url;
use crate::data::w_cfg;
//use data::Notify as Notify;

pub mod data;
pub mod refresh;
pub mod token;
pub mod session;
pub mod notify;
pub mod notify_read;
pub mod reply;
pub mod reply_link;
pub mod describe;
pub mod timeline_author;

fn main() {
    let args: Vec<String> = env::args().collect();
    let app = App::new(env!("CARGO_PKG_NAME"))
        .command(
            Command::new("login")
            .alias("l")
            .description("l <handle> -p <password>\n\t\t\tl <handle> -p <password> -s <server>")
            .action(token)
            .flag(
                Flag::new("password", FlagType::String)
                .description("password flag")
                .alias("p"),
                )
            .flag(
                Flag::new("server", FlagType::String)
                .description("server flag")
                .alias("s"),
            )
        )
        .command(
            Command::new("refresh")
            .alias("r")
            .action(refresh),
        )
        .command(
            Command::new("notify")
            .alias("n")
            .action(notify),
            )
        .command(
            Command::new("timeline")
            .alias("t")
            .action(timeline),
        )
        .command(
            Command::new("did")
            .description("did <handle>")
            .action(did)
            )
        ;
    app.run(args);
}

fn token(c: &Context) {
    let m = c.args[0].to_string();
    let h = async {
        if let Ok(p) = c.string_flag("password") {
            if let Ok(s) = c.string_flag("server") {
                let res = token::post_request(m.to_string(), p.to_string(), s.to_string()).await;
                w_cfg(&s, &res)
            } else {
                let res = token::post_request(m.to_string(), p.to_string(), "bsky.social".to_string()).await;
                w_cfg(&"bsky.social", &res)
            }
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn refresh(_c: &Context) {
    let server = data_toml(&"host");
    let h = async {
        let session = session::get_request().await;
        if session == "err" {
            let res = refresh::post_request().await;
            println!("{}", res);
            w_cfg(&server, &res)
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn notify(c: &Context) {
    refresh(c);
    let h = async {
        let j = notify::get_request(100).await;
        println!("{}", j);
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn did(c: &Context) {
    refresh(c);
    let h = async {
        if c.args.len() == 0 {
            let j = describe::get_request(data_toml(&"handle")).await;
            println!("{}", j);
        } else {
            let j = describe::get_request(c.args[0].to_string()).await;
            println!("{}", j);
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}

fn timeline(c: &Context) {
    refresh(c);
    let h = async {
        if c.args.len() == 0 {
            let str = timeline_author::get_request(data_toml(&"handle").to_string());
            println!("{}",str.await);    
        } else {
            let str = timeline_author::get_request(c.args[0].to_string());
            println!("{}",str.await);    
        }
    };
    let res = tokio::runtime::Runtime::new().unwrap().block_on(h);
    return res
}
