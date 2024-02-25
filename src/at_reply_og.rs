extern crate reqwest;
use crate::token_toml;
use crate::url;
use serde_json::json;
use iso8601_timestamp::Timestamp;

pub async fn post_request(m: String, link: String, cid: String, uri: String, cid_b: String, uri_b: String, img: String, title: String, description: String) -> String {

    let token = token_toml(&"access");
    let did = token_toml(&"did");
    let handle = token_toml(&"handle");

    let url = url(&"record_create");
    let col = "app.bsky.feed.post".to_string();

    let d = Timestamp::now_utc();
    let d = d.to_string();

    let post = Some(json!({
        "repo": handle.to_string(),
        "did": did.to_string(),
        "collection": col.to_string(),
        "record": {
            "createdAt": d.to_string(),
            "text": m.to_string(),
            "embed": {
                "$type": "app.bsky.embed.external",
                "external": {
                    "uri": link.to_string(),
                    "thumb": {
                      "$type": "blob",
                      "ref": {
                        "$link": img.to_string()
                      },
                      "mimeType": "image/jpeg",
                      "size": 0
                    },
                    "title": title.to_string(),
                    "description": description.to_string()
                }
            },
            "reply": {
                "root": {
                    "cid": cid_b.to_string(),
                    "uri": uri_b.to_string()
                },
                "parent": {
                    "cid": cid.to_string(),
                    "uri": uri.to_string()
                }
            }
        }
    }));

    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .json(&post)
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
