Test traefik mTLS setup

[minica](https://github.com/fopina/minica/releases/tag/v1.0.2-1) used to generate certs:

```
minica -ca-cert good-one.pem -ca-cn "good-one" -domains '*.7f000001.nip.io'
minica -ca-cert bad-one.pem -ca-cn "reject-me" -domains '*.7f000001.nip.io'
```