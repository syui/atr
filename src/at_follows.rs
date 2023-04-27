extern crate reqwest;
use crate::token_toml;
use crate::url;
//use serde_json::json;

pub async fn get_request(actor: String, cursor: Option<String>) -> String {

    let token = token_toml(&"access");
    let url = url(&"follows");
    let cursor = cursor.unwrap();
    //let cursor = "1682386039125::bafyreihwgwozmvqxcxrhbr65agcaa4v357p27ccrhzkjf3mz5xiozjvzfa".to_string();
    //let cursor = "1682385956974::bafyreihivhux5m3sxbg33yruhw5ozhahwspnuqdsysbo57smzgptdcluem".to_string();

    let client = reqwest::Client::new();
        let res = client
            .get(url)
            .query(&[("actor", actor),("cursor", cursor)])
            //cursor.unwrap()
            .header("Authorization", "Bearer ".to_owned() + &token)
            .send()
            .await
            .unwrap()
            .text()
            .await
            .unwrap();
        return res
}
