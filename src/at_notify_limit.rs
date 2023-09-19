extern crate reqwest;
use crate::token_toml;
use crate::url;
//use serde_json::json;

pub async fn get_request(limit: i32, ) -> String {

    let token = token_toml(&"access");
    let url = url(&"notify_list");

    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("limit", limit)])
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap();

    let status_ref = res.error_for_status_ref();

    match status_ref {
        Ok(_) => {
            return res.text().await.unwrap();
        },
        Err(_e) => {
            let e = "err".to_string();
            return e
        }
    }
}
