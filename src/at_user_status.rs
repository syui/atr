extern crate reqwest;
use crate::url;

pub async fn get_request(user: String) -> String {

    let url = url(&"describe");

    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("repo", &user)])
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
