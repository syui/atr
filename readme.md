`art` is cli client for at written in rust.

[download](https://github.com/syui/atr/releases)

```sh
# example
$ curl -sLO https://github.com/syui/atr/releases/download/latest/atr-x86_64-apple-darwin
$ mv atr-* atr
$ chmod +x atr
$ ./atr
```

### build

support :  cargo 1.67.1

err : cargo 1.6.8.x

> rejected by a future version of Rust: rustc-serialize v0.3.24


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

### did

```sh
$ atr s syui.bsky.social -d
or
$ atr did syui.bsky.social
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
# like
## atr like $cid -u $uri
$ atr like bafyreieb7cbrjg646h65yaufv6fkzytg4iqff2n7p6ge2kcwmm7jzgowde -u "at://did:plc:a6sw7vngvr3qyqb4vgaxnmp5/app.bsky.feed.post/3jtsgga3nxx2z"

# repost
$ atr repost bafyreieb7cbrjg646h65yaufv6fkzytg4iqff2n7p6ge2kcwmm7jzgowde -u "at://did:plc:a6sw7vngvr3qyqb4vgaxnmp5/app.bsky.feed.post/3jtsgga3nxx2z"
```

```sh
# follow
## atr follow $did
$ atr follow did:plc:uqzpqmrjnptsxezjx4xuh2mn

# get follows
$ atr follow -s

# get followers
$ atr follow -w

# next
$ atr follow -s -c $cursor
$ atr follow -w -c $cursor

# unfollow
# at://did:plc:uqzpqmrjnptsxezjx4xuh2mn/app.bsky.graph.follow/xxx
# rkey = xxx
$ atr follow $did -d $rkey

# all follow back
$ cp -rf scpt ~/.config/atr/
$ atr follow -a
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

```sh
$ atr deepl-api "xxx"

# deepl translate [en -> ja]
$ atr tt "test" -l ja
# deepl translate [ja -> en]
$ atr tt "テスト" -l en

$ atr p "deeplで翻訳してポストしています" -e
Translated and posted by deepl

$ atr p "Translated and posted by deepl" -j
deeplで翻訳してポストしています
```

```sh
$ atr openai-api "xxx"
$ atr chat "Lexicon is a schema system used to define RPC methods and record types"
It is used in distributed systems to define the various components, such as clients, servers, and databases, and their interactions. Lexicon is often used to define the data structure for RPC methods and records, and to define the communications protocols between the various components of a distributed system.
```

```sh
# reply
$ atr r "reply post" -c $cid -u $uri

# test : post reply option
$ atr p "[en -> ja] translate and post the english to japanese with deepl" -j --cid $cid --uri $uri
$ atr p "[chatgpt] post by openai chatgpt" -c --cid $cid --uri $uri
```

```sh
# test : bot
$ atr bot

# notify read
$ atr n --cid
$ f=$HOME/.config/atr/notify_cid.txt;cat $f |tail -n 1000 >! $f.back;mv $f.back $f
```

```sh
# x) curbing double mention and reply
# cron : * * * * * atr bot
# cron : * */1 * * * atr bot -m true
```

```sh
# img-upload & img-post
$ atr img-upload ~/img.png
$ atr img-post $text -l $link

$ link=`atr img-upload ~/icloud/icon/ai_circle.png|jq -r .blob.ref.'"$link"'`;atr img-post test -l $link
```

```sh
# timeline bot
$ atr bot-tl

# timeline
$ atr ss -s
# post
$ atr ss -d
```

### ref

openai : https://github.com/syui/msr/tree/openai

deepl : https://github.com/syui/msr/tree/deepl

at : https://atproto.com/guides/lexicon
