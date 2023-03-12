extern crate reqwest;
use crate::token_toml;
use crate::url;

pub async fn get_request() -> String {

    let token = token_toml(&"access");
    let url = url(&"timeline_get");

    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
