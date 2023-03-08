at clietn rust

```sh
$ mkdir -p ~/.config/atr
$ cp example.config.toml ~/.config/atr/config.toml
$ cat ~/.config/atr/config.toml
host = "bsky.social"
pass = "xxx"
user = "ai.bsky.social"
```

```sh
# status
$ cargo build
$ ./target/debug/atr s
$ ./target/debug/atr s -u syui.bsky.social
```

```sh
# feed
$ atr f
$ atr f -u syui.bsky.social
```

```sh
# post
$ ./target/debug/atr p "post message"
# timeline
$ ./target/debug/atr t

# media post
$ ./target/debug/atr m ~/test.png
```

```sh
# custom handle
$ atr h te.bsky.social
$ vim ~/.config/atr/config.toml
user = "te.bsky.social"
$ atr a
$ atr t
```

```sh
# account create
$ cat ~/.config/atr/config.toml
user = "syui.bsky.social"
pass = "xxx"
host = "bsky.social"

$ atr c -i ${invite_code} -e user@example.com
```
