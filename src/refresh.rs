extern crate reqwest;
use crate::data_toml;
use crate::url;

pub async fn post_request() -> String {
    let refresh = data_toml(&"refresh");
    let url = url(&"session_refresh");

    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .header("Authorization", "Bearer ".to_owned() + &refresh)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
