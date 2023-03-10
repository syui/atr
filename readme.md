`art` is cli clietn for at written in rust.

[download](https://github.com/syui/atr/releases)

```sh
# example
$ curl -sLO https://github.com/syui/atr/releases/download/latest/atr-x86_64-apple-darwin
$ mv atr-* atr
$ chmod +x atr
$ ./atr
```

### build

```sh
# install rust
$ sudo pacman -S rust
```

```sh
$ cargo build
$ ./target/debug/atr s
$ ./target/debug/atr s -u syui.bsky.social
```

### start

```sh
# login
$ atr start -u syui.bsky.social -p xxx
$ atr t
```

> ~/.config/atr/config.toml

```toml
host = "bsky.social"
pass = "xxx"
user = "syui.bsky.social"
```

### use

```sh
# feed
$ atr f
$ atr f -u syui.bsky.social
```

```sh
# post
$ atr p "post message"
# post link
$ atr p "post message" -l https://syui.cf

# timeline
$ atr t


# media post
$ atr m ~/test.png
```

```sh
# custom handle
$ atr h te.bsky.social
$ vim ~/.config/atr/config.toml
user = "syui.bsky.social"
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
