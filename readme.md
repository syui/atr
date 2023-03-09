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
# post link
$ ./target/debug/atr p "post message" -l https://syui.cf

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

```sh
# mention
$ atr @ syui.bsky.social
$ atr @ syui.bsky.social -p "message"
```

```sh
# account switch
$ cp -rf ~/.config/atr/config.toml ~/.config/atr/social.toml 
$ cp -rf ~/.config/atr/config.toml ~/.config/atr/setting.toml 

$ atr ss -d
$ atr ss -s

# prompt
my_bluesky() {
		source ~/.config/atr/atr.zsh
		if [ "${BLUESKY_BASE}" = "syui.cf" ];then
			export bluesky="%F{blue}${icon_bluesky} : @${BLUESKY_BASE}.bsky.social%f"
		else
			export bluesky="%F{red}${icon_bluesky} : @${BLUESKY_BASE}%f"
		fi
	}
autoload -Uz add-zsh-hook
add-zsh-hook precmd my_bluesky
```
