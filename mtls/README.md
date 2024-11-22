Test traefik mTLS setup

[minica](https://github.com/fopina/minica/releases/tag/v1.0.2-1) used to generate certs:

```
minica -ca-cert good-one.pem -ca-key good-one-key.pem -ca-cn "good-one" -domains '*.7f000001.nip.io'
minica -ca-cert good-one.pem -ca-key good-one-key.pem -domains 'good-client'
minica -ca-cert bad-one.pem -ca-key bad-one-key.pem -ca-cn "reject-me" -domains 'bad-client'
```