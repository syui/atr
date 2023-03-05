use config::{Config, ConfigError, File};
use serde_derive::Deserialize;
//use std::borrow::Cow;

#[derive(Debug, Deserialize)]
#[allow(unused)]
pub struct Data {
    pub host: String,
    pub pass: String,
    pub user: String,
}

impl Data {
    pub fn new() -> Result<Self, ConfigError> {
        let d = shellexpand::tilde("~") + "/.config/atr/config.toml";
        let s = Config::builder()
            .add_source(File::with_name(&d))
            .add_source(config::Environment::with_prefix("APP"))
            .build()?;
        s.try_deserialize()
    }
}

