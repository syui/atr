extern crate reqwest;
use crate::Deeps;
use crate::DeepData;
use reqwest::header::AUTHORIZATION;
use reqwest::header::CONTENT_TYPE;
use std::collections::HashMap;

pub async fn post_request(prompt: String, lang: String) -> String {
    let lang = lang.to_string();
    let data = Deeps::new().unwrap();
    let data = Deeps {
        api: data.api,
    };
    let api = "DeepL-Auth-Key ".to_owned() + &data.api;
    let mut params = HashMap::new();
    params.insert("text", &prompt);
    params.insert("target_lang", &lang);
    let client = reqwest::Client::new();
    let res = client
        .post("https://api-free.deepl.com/v2/translate")
        .header(AUTHORIZATION, api)
        .header(CONTENT_TYPE, "json")
        .form(&params)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    let p: DeepData = serde_json::from_str(&res).unwrap();
    let o = &p.translations[0].text;
    return o.to_string()
}
