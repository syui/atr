extern crate reqwest;
use crate::data_toml;
use crate::url;

pub async fn get_request() -> String {

    let token = data_toml(&"access");
    let url = url(&"session_get");

    let client = reqwest::Client::new();
    let res = client
        .get(url)
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
