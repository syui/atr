at clietn rust

```sh
$ mkdir -p ~/.config/atr
$ cp example.config.toml ~/.config/atr/config.toml
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


