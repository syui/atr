extern crate reqwest;
use crate::token_toml;
use crate::url;
use serde_json::json;
use iso8601_timestamp::Timestamp;

pub async fn post_request(text: String, cid: String, uri: String, mid: String, itype: String) -> String {

    let token = token_toml(&"access");
    let did = token_toml(&"did");

    let url = url(&"record_create");
    //let url = "https://bsky.social/xrpc/com.atproto.repo.createRecord";
    let col = "app.bsky.feed.post".to_string();

    let d = Timestamp::now_utc();
    let d = d.to_string();

    //{
    //  "did": "",
    //  "collection": "",
    //  "record": {
    //    "text": "",
    //    "createdAt": "",
    //    "": "",
    //    "embed": {
    //      "$type": "app.bsky.embed.images",
    //      "images": [
    //        {
    //          "image": {
    //            "cid": "",
    //            "mimeType": ""
    //          },
    //          "alt": ""
    //        }
    //      ]
    //    }
    //  }
    //}
    
    let post = Some(json!({
        "did": did.to_string(),
        "collection": col.to_string(),
        "record": {
            "text": text.to_string(),
            "createdAt": d.to_string(),
            "embed": {
                "$type": "app.bsky.embed.images",
                "images": [
                {
                    "image": {
                        "cid": mid.to_string(),
                        "mimeType": itype.to_string()
                    },
                    "alt": ""
                }
                ]
            },
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
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
