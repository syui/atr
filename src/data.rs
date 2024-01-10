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
    pub record_delete: String,
    pub session_create: String,
    pub session_refresh: String,
    pub session_get: String,
    pub timeline_get: String,
    pub timeline_author: String,
    pub upload_blob: String,
    pub update_handle: String,
    pub account_create: String,
    pub notify_count: String,
    pub notify_list: String,
    pub notify_update: String,
    pub repo_update: String,
    pub like: String,
    pub repost: String,
    pub follow: String,
    pub follows: String,
    pub followers: String,
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
        profile_get: "com.atproto.identity.resolveHandle".to_string(),
        record_create: "com.atproto.repo.createRecord".to_string(),
        record_delete: "com.atproto.repo.deleteRecord".to_string(),
        describe: "com.atproto.repo.describeRepo".to_string(),
        record_list: "com.atproto.repo.listRecords".to_string(),
        session_create: "com.atproto.server.createSession".to_string(),
        session_refresh: "com.atproto.server.refreshSession".to_string(),
        session_get: "com.atproto.server.getSession".to_string(),
        timeline_get: "app.bsky.feed.getTimeline".to_string(),
        timeline_author: "app.bsky.feed.getAuthorFeed".to_string(),
        like: "app.bsky.feed.like".to_string(),
        repost: "app.bsky.feed.repost".to_string(),
        follow: "app.bsky.graph.follow".to_string(),
        follows: "app.bsky.graph.getFollows".to_string(),
        followers: "app.bsky.graph.getFollowers".to_string(),
        upload_blob: "com.atproto.repo.uploadBlob".to_string(),
        account_create: "com.atproto.server.createAccount".to_string(),
        update_handle: "com.atproto.identity.updateHandle".to_string(),
        notify_count: "app.bsky.notification.getUnreadCount".to_string(),
        notify_list: "app.bsky.notification.listNotifications".to_string(),
        notify_update: "app.bsky.notification.updateSeen".to_string(),
        repo_update: "com.atproto.sync.updateRepo".to_string(),
    };

    match &*s {
        "profile_get" => t.to_string() + &baseurl.profile_get,
        "describe" => t.to_string() + &baseurl.describe,
        "record_list" => t.to_string() + &baseurl.record_list,
        "record_create" => t.to_string() + &baseurl.record_create,
        "record_delete" => t.to_string() + &baseurl.record_delete,
        "session_create" => t.to_string() + &baseurl.session_create,
        "session_refresh" => t.to_string() + &baseurl.session_refresh,
        "session_get" => t.to_string() + &baseurl.session_get,
        "timeline_get" => t.to_string() + &baseurl.timeline_get,
        "timeline_author" => t.to_string() + &baseurl.timeline_get,
        "upload_blob" => t.to_string() + &baseurl.upload_blob,
        "account_create" => t.to_string() + &baseurl.account_create,
        "update_handle" => t.to_string() + &baseurl.update_handle,
        "notify_list" => t.to_string() + &baseurl.notify_list,
        "notify_count" => t.to_string() + &baseurl.notify_count,
        "notify_update" => t.to_string() + &baseurl.notify_update,
        "repo_update" => t.to_string() + &baseurl.repo_update,
        "like" => t.to_string() + &baseurl.like,
        "repost" => t.to_string() + &baseurl.repost,
        "follow" => t.to_string() + &baseurl.follow,
        "follows" => t.to_string() + &baseurl.follows,
        "followers" => t.to_string() + &baseurl.followers,
        _ => s,
    }
}

#[derive(Serialize, Deserialize)]
pub struct Notify {
    pub notifications: Vec<Notifications>
}

#[derive(Serialize, Deserialize)]
pub struct Status {
    pub handle: String,
    pub did: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct DidDocs {
    pub verificationMethod: Vec<VerificationMethod>,
    pub service: Vec<Service>,
    pub id: String,
    pub alsoKnownAs: Vec<AlsoKnownAs>,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct VerificationMethod {
    pub id: String,
    pub r#type: String,
    pub controller: String,
    pub publicKeyMultibase: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Service {
    pub id: String,
    pub r#type: String,
    pub serviceEndpoint: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct AlsoKnownAs {
}

#[derive(Serialize, Deserialize)]
pub struct Timeline {
    pub feed: Vec<Feed>
}
#[derive(Serialize, Deserialize)]
pub struct Session {
    pub did: String,
    pub email: String,
    pub handle: String,
}
#[derive(Serialize, Deserialize)]
pub struct Follow {
    pub follows: Vec<Author>,
    pub cursor: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Notifications {
    pub uri: String,
    pub cid: String,
    pub author: Author,
    pub reason: String,
    //pub reasonSubject: String,
    pub record: Record,
    pub isRead: bool,
    pub indexedAt: String,
    //pub labels: Labels,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Author {
    pub did: String,
    //pub declaration: Declaration,
    pub description: Option<String>,
    pub displayName: Option<String>,
    pub handle: String,
    pub avatar: Option<String>,
    pub viewer: Viewer,
    //pub labels: Labels,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Labels {
    pub src: Option<String>,
    pub uri: Option<String>,
    pub cid: Option<String>,
    pub val: Option<String>,
    pub cts: Option<String>,
    pub neg: Option<bool>,
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
    //pub langs: Option<Langs>,
    pub text: Option<String>,
    pub createdAt: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Langs {
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
    pub postCount: Option<i32>,
    pub repostCount: i32,
    pub likeCount: i32,
}

#[derive(Serialize, Deserialize)]
pub struct Cid {
    pub cid: String
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Img {
    pub blob: Blob
}

#[derive(Serialize, Deserialize)]
pub struct Blob {
    pub r#ref: Ref,
}

#[derive(Serialize, Deserialize)]
pub struct Ref {
    pub link: String,
}

#[derive(Serialize, Deserialize)]
pub struct Handle {
    pub handle: String
}

//#[derive(Serialize, Deserialize)]
//pub struct Did {
//    pub did: String
//}

//#[derive(Serialize, Deserialize)]
//pub struct Labels {
//}
//
//#[derive(Serialize, Deserialize)]
//pub struct Viewer {
//    pub muted: bool,
//    pub blockedBy: bool,
//}
//
#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct ProfileIdentityResolve {
    pub did: String,
}

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
pub struct Profile {
    pub did: String,
    pub handle: String,
    pub followsCount: Option<i32>,
    pub followersCount: Option<i32>,
    pub postsCount: i32,
    pub indexedAt: Option<String>,
    pub avatar: Option<String>,
    pub banner: Option<String>,
    pub displayName: Option<String>,
    pub description: Option<String>,
    pub viewer: Viewer,
    pub labels: Labels,
}

//
//  "did": "did:plc:uqzpqmrjnptsxezjx4xuh2mn",
//  "handle": "syui.ai",
//  "displayName": "syui",
//  "avatar": "https://cdn.bsky.social/imgproxy/aSbqSRpqXSxkXBRpRODZUEquXcWOdaBXiwtPcMvmXZM/rs:fill:1000:1000:1:0/plain/bafkreid6kcc5pnn4b3ar7mj6vi3eiawhxgkcrw3edgbqeacyrlnlcoetea@jpeg",
//  "banner": "https://cdn.bsky.social/imgproxy/OAuuvXAKZpWzPm6pCcAC0R07npMexrWoOiNELnW_iw0/rs:fill:3000:1000:1:0/plain/bafkreih4axx4k243yd5zbj5zrehzm6cramzl6tsygubqgwzagxar7re34u@jpeg",
//  "followsCount": 1083,
//  "followersCount": 1044,
//  "postsCount": 3925,
//  "indexedAt": "2023-04-15T08:30:29.809Z",
//  "viewer": {
//    "muted": false,
//    "blockedBy": false
//  },
//  "labels": []
//
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
