use config::{Config, ConfigError, File};
use serde_derive::{Deserialize, Serialize};
//use std::borrow::Cow;

#[derive(Debug, Deserialize)]
#[allow(unused)]
pub struct Data {
    pub host: String,
    pub pass: String,
    pub user: String,
}

impl Data {
    pub fn new() -> Result<Self, ConfigError> {
        let d = shellexpand::tilde("~") + "/.config/atr/config.toml";
        let s = Config::builder()
            .add_source(File::with_name(&d))
            .add_source(config::Environment::with_prefix("APP"))
            .build()?;
        s.try_deserialize()
    }
}

// at://
// https://atproto.com/lexicons/app-bsky-feed
#[derive(Serialize, Deserialize)]
pub struct Notify {
    pub notifications: Vec<Notifications>
}
#[derive(Serialize, Deserialize)]
pub struct Timeline {
    pub feed: Vec<Feed>
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Notifications {
    pub uri: String,
    pub cid: String,
    pub author: Author,
    pub reason: String,
    pub record: Record,
    pub isRead: bool,
    pub indexedAt: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Author {
    pub did: String,
    pub declaration: Declaration,
    pub handle: String,
    pub avatar: Option<String>,
    pub viewer: Viewer
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Declaration {
    pub actorType: String,
    pub cid: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Viewer {
    pub muted: bool,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Token {
    pub did: String,
    pub accessJwt: String,
    pub refreshJwt: String,
    pub handle: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Record {
    pub text: Option<String>,
    pub createdAt: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Feed {
    pub post: Post,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Post {
    pub did: Option<String>,
    pub uri: String,
    pub collection: Option<String>,
    pub record: Record,
    pub author: Author,
    pub reason: Option<String>,
    pub indexedAt: String,
    pub replyCount: i32,
    pub repostCount: i32,
    pub upvoteCount: i32,
    pub downvoteCount: i32,
}

#[derive(Serialize, Deserialize)]
pub struct Cid {
    pub cid: String
}

#[derive(Serialize, Deserialize)]
pub struct Handle {
    pub handle: String
}

#[derive(Serialize, Deserialize)]
pub struct Did {
    pub did: String
}

