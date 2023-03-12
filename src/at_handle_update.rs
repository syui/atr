extern crate reqwest;
use crate::token_toml;
use crate::url;
use crate::Handle;

pub async fn post_request(handle: String) -> String {

    let token = token_toml(&"access");
    let did = token_toml(&"did");
    let url = url(&"update_handle");

    println!("DNS txt : _atproto.{}, did={}.", handle, did);

    let handle = Handle {
        handle: handle.to_string()
    };

    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .json(&handle)
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
