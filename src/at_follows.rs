extern crate reqwest;
use crate::token_toml;
use crate::url;
//use serde_json::json;

pub async fn get_request(actor: String) -> String {

    let token = token_toml(&"access");
    let url = url(&"follows");

    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("actor", actor)])
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
