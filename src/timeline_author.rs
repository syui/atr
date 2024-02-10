extern crate reqwest;
use crate::data_toml;
use crate::url;

pub async fn get_request(actor: String) -> String {

    let token = data_toml(&"access");
    let url = url(&"record_list");

    let actor = actor.to_string();
    //let cursor = cursor.unwrap();

    let col = "app.bsky.feed.post".to_string();
    let client = reqwest::Client::new();
    let res = client
        .get(url)
        .query(&[("repo", actor),("collection", col)])
        //.query(&[("actor", actor),("cursor", cursor)])
        .header("Authorization", "Bearer ".to_owned() + &token)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    return res
}
