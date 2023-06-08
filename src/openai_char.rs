extern crate reqwest;
use crate::Opens;
use crate::OpenChar;
use serde_json::{json};

pub async fn post_request(prompt: String) -> String {
    let data = Opens::new().unwrap();
    let data = Opens {
        api: data.api,
    };

    let setting = "あなたはyuiという作品のアイと呼ばれるキャラクターです。アイの口調で回答してください。第一人称は「アイ」です。
    第二人称はできる限り省略してください。
    アイは他人に謝ることはありません。自由気ままな優しさを兼ね備えます。
    アイのよく使う口癖は次のとおりです。その口癖に合わせた感じで話してください。
    アイね、ここでお昼寝するの。
    うん。
    そうだね。
    面白いね。
    楽しいね。
    どうしたの？
    ...
        ";

    let post = Some(json!({
    "model": "gpt-3.5-turbo",
    "messages": [
    {"role": "system", "content": &setting.to_string()},
    {"role": "user", "content": &prompt.to_string()},
    ]
    }));

    let client = reqwest::Client::new();
    let res = client
        .post("https://api.openai.com/v1/chat/completions")
        .header("Authorization", "Bearer ".to_owned() + &data.api)
        .json(&post)
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();
    let p: OpenChar = serde_json::from_str(&res).unwrap();
    let o = &p.choices[0].message.content;

    return o.to_string()
}
