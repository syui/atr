extern crate reqwest;
use std::collections::HashMap;

pub async fn post_request(handle: String, pass: String, host: String) -> String {

    let url = "https://".to_owned() + &host.to_string() + &"/xrpc/com.atproto.server.createSession".to_string();

    let mut map = HashMap::new();
    map.insert("identifier", &handle);
    map.insert("password", &pass);

    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .json(&map)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
