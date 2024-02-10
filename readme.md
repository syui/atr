## atr

[atproto](https://github.com/bluesky-social/atproto) rust client

```sh
$ cargo build
$ ./target/debug/atr
```

```sh
handle=syui.bsky.social
password=xxx

$ atr login $handle -p $password
```

```sh
$ cat ~/.config/atr/token.toml
```

### did

```sh
$ atr did
```

[jq](https://jqlang.github.io/jq/)

```sh
$ atr did|jq .
{
  "handle": "syui.ai",
  "did": "did:plc:uqzpqmrjnptsxezjx4xuh2mn",
  "didDoc": {
    "@context": [
      "https://www.w3.org/ns/did/v1",
      "https://w3id.org/security/multikey/v1",
      "https://w3id.org/security/suites/secp256k1-2019/v1"
    ],
    "id": "did:plc:uqzpqmrjnptsxezjx4xuh2mn",
    "alsoKnownAs": [
      "at://syui.ai"
    ],
    "verificationMethod": [
      {
        "id": "did:plc:uqzpqmrjnptsxezjx4xuh2mn#atproto",
        "type": "Multikey",
        "controller": "did:plc:uqzpqmrjnptsxezjx4xuh2mn",
        "publicKeyMultibase": "zQ3shPfu6758hmFcsNNdWvaGWiVsk9KGmiTYQUYGzyWxVmLK8"
      }
    ],
    "service": [
      {
        "id": "#atproto_pds",
        "type": "AtprotoPersonalDataServer",
        "serviceEndpoint": "https://shiitake.us-east.host.bsky.network"
      }
    ]
  },
  "collections": [
    "app.bsky.actor.profile",
    "app.bsky.feed.like",
    "app.bsky.feed.post",
    "app.bsky.feed.repost",
    "app.bsky.graph.follow"
  ],
  "handleIsCorrect": true
}
```

### timeline

```sh
$ atr t
```

### notify

```sh
$ atr n
```
