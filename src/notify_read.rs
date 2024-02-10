extern crate reqwest;
use crate::data_toml;
use crate::url;
use serde_json::json;

pub async fn post_request(time: String) -> String {

    let token = data_toml(&"access");
    let url = url(&"notify_update");

    let post = Some(json!({
        "seenAt": time.to_string(),
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
