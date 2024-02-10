extern crate reqwest;
//use crate::data_toml;
use crate::url;

pub async fn get_request(user: String) -> String {

    //let token = data_toml(&"access");
    let url = url(&"describe");

    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("repo", &user)])
        //.header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
