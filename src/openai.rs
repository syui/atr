extern crate reqwest;
use crate::Opens;
use crate::OpenData;
use serde_json::{json};

pub async fn post_request(prompt: String, model: String) -> String {
    let data = Opens::new().unwrap();
    let data = Opens {
        api: data.api,
    };

    let temperature = 0.7;
    let max_tokens = 250;
    let top_p = 1;
    let frequency_penalty = 0;
    let presence_penalty = 0;
    let stop = "[\"###\"]";

    let post = Some(json!({
        "prompt": &prompt.to_string(),
        "model": &model.to_string(),
        "temperature": temperature,
        "max_tokens": max_tokens,
        "top_p": top_p,
        "frequency_penalty": frequency_penalty,
        "presence_penalty": presence_penalty,
        "stop": stop,
    }));

    let client = reqwest::Client::new();
    let res = client
        .post("https://api.openai.com/v1/completions")
        .header("Authorization", "Bearer ".to_owned() + &data.api)
        .json(&post)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();
    let p: OpenData = serde_json::from_str(&res).unwrap();
    let o = &p.choices[0].text;

    return o.to_string()
}
