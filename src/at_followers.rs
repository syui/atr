extern crate reqwest;
use crate::token_toml;
use crate::url;
//use serde_json::json;

pub async fn get_request(actor: String,cursor: Option<String>) -> String {

    let token = token_toml(&"access");
    let url = url(&"followers");
    let cursor = cursor.unwrap();

    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("actor", actor),("cursor", cursor)])
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
