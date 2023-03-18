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
pub struct Tokens {
    pub did: String,
    pub access: String,
    pub refresh: String,
    pub handle: String,
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

impl Tokens {
    pub fn new() -> Result<Self, ConfigError> {
        let d = shellexpand::tilde("~") + "/.config/atr/token.toml";
        let s = Config::builder()
            .add_source(File::with_name(&d))
            .add_source(config::Environment::with_prefix("APP"))
            .build()?;
        s.try_deserialize()
    }
}
// config.data
pub fn cfg(s: &str) -> String { 
    // cfg.dir
    let dir = "/.config/atr";
    let mut d = shellexpand::tilde("~").to_string();
    d.push_str(&dir);

    let file = "/.config/atr/config.toml";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);

    //cfg.toml
    let s = String::from(s);
    let data = Data::new().unwrap();
    let data = Data {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    match &*s {
        "user" => data.user,
        "host" => data.host,
        "pass" => data.pass,
        "dir" => d,
        "file" => f,
        _ => s,
    }
}

// tokne.file
pub fn token_file(s: &str) -> String { 
    let file = "/.config/atr/token";
    let mut f = shellexpand::tilde("~").to_string();
    f.push_str(&file);
    match &*s {
        "toml" => f + &".toml",
        "json" => f + &".json",
        _ => f + &"." + &s,
    }
}

pub fn token_toml(s: &str) -> String { 
    let s = String::from(s);
    let tokens = Tokens::new().unwrap();
    let tokens = Tokens {
        did: tokens.did,
        access: tokens.access,
        refresh: tokens.refresh,
        handle: tokens.handle,
    };
    match &*s {
        "did" => tokens.did,
        "access" => tokens.access,
        "refresh" => tokens.refresh,
        "handle" => tokens.handle,
        _ => s,
    }
}

// at://
// https://atproto.com/lexicons/app-bsky-feed
#[derive(Serialize, Deserialize)]
pub struct BaseUrl {
    pub profile_get: String,
    pub describe: String,
    pub record_list: String,
    pub record_create: String,
    pub session_create: String,
    pub timeline_get: String,
    pub upload_blob: String,
    pub update_handle: String,
    pub account_create: String,
    pub notify_count: String,
    pub notify_list: String,
    pub notify_update: String,
    pub repo_update: String,
    pub follow: String,
}

pub fn url(s: &str) -> String {
    let s = String::from(s);
    let data = Data::new().unwrap();
    let data = Data {
        host: data.host,
        user: data.user,
        pass: data.pass,
    };
    let t = "https://".to_string() + &data.host.to_string() + &"/xrpc/".to_string();
    let baseurl = BaseUrl {
        profile_get: "app.bsky.actor.getProfile".to_string(),
        record_create: "com.atproto.repo.createRecord".to_string(),
        describe: "com.atproto.repo.describe".to_string(),
        record_list: "com.atproto.repo.listRecords".to_string(),
        session_create: "com.atproto.session.create".to_string(),
        timeline_get: "app.bsky.feed.getTimeline".to_string(),
        upload_blob: "com.atproto.blob.upload".to_string(),
        account_create: "com.atproto.account.create".to_string(),
        update_handle: "com.atproto.handle.update".to_string(),
        notify_count: "app.bsky.notification.getCount".to_string(),
        notify_list: "app.bsky.notification.list".to_string(),
        notify_update: "app.bsky.notification.updateSeen".to_string(),
        repo_update: "com.atproto.sync.updateRepo".to_string(),
        follow: "app.bsky.graph.follow".to_string(),
    };
    match &*s {
        "profile_get" => t.to_string() + &baseurl.profile_get,
        "describe" => t.to_string() + &baseurl.describe,
        "record_list" => t.to_string() + &baseurl.record_list,
        "record_create" => t.to_string() + &baseurl.record_create,
        "session_create" => t.to_string() + &baseurl.session_create,
        "timeline_get" => t.to_string() + &baseurl.timeline_get,
        "upload_blob" => t.to_string() + &baseurl.upload_blob,
        "account_create" => t.to_string() + &baseurl.account_create,
        "update_handle" => t.to_string() + &baseurl.update_handle,
        "notify_list" => t.to_string() + &baseurl.notify_list,
        "notify_count" => t.to_string() + &baseurl.notify_count,
        "notify_update" => t.to_string() + &baseurl.notify_update,
        "repo_update" => t.to_string() + &baseurl.repo_update,
        "follow" => t.to_string() + &baseurl.follow,
        _ => s,
    }
}

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
    pub cid: String,
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

//#[derive(Serialize, Deserialize)]
//pub struct Did {
//    pub did: String
//}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Profile {
    pub did: String,
    pub handle: String,
    //pub followCount: String,
    //pub followersCount: String,
    //pub postsCount: String,
    //pub creator: String,
    //pub indexedAt: String,
    //pub avatar: Option<String>,
    //pub banner: Option<String>,
    //pub displayName: Option<String>,
    //pub description: Option<String>,
}

#[derive(Debug, Deserialize)]
#[allow(unused)]
pub struct Deep {
    pub api: String,
}

impl Deep {
    pub fn new() -> Result<Self, ConfigError> {
        let d = shellexpand::tilde("~") + "/.config/atr/deepl.toml";
        let s = Config::builder()
            .add_source(File::with_name(&d))
            .add_source(config::Environment::with_prefix("APP"))
            .build()?;
        s.try_deserialize()
    }
}

impl Open {
    pub fn new() -> Result<Self, ConfigError> {
        let d = shellexpand::tilde("~") + "/.config/atr/openai.toml";
        let s = Config::builder()
            .add_source(File::with_name(&d))
            .add_source(config::Environment::with_prefix("APP"))
            .build()?;
        s.try_deserialize()
    }
}

#[derive(Debug, Deserialize)]
#[allow(unused)]
pub struct Open {
    pub api: String,
}
