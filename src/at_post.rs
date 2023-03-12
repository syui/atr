extern crate reqwest;
use crate::token_toml;
use crate::url;
use serde_json::json;
use iso8601_timestamp::Timestamp;

pub async fn post_request(text: String) -> String {

    let token = token_toml(&"access");
    let did = token_toml(&"did");

    let url = url(&"record_create");
    let col = "app.bsky.feed.post".to_string();

    let d = Timestamp::now_utc();
    let d = d.to_string();

    let post = Some(json!({
        "did": did.to_string(),
        "collection": col.to_string(),
        "record": {
            "text": text.to_string(),
            "createdAt": d.to_string(),
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
