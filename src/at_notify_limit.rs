extern crate reqwest;
use crate::token_toml;
use crate::url;
//use serde_json::json;

pub async fn get_request(limit: i32) -> String {

    let token = token_toml(&"access");
    let url = url(&"notify_list");

    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("limit", limit)])
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
