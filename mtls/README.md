Test traefik mTLS setup

[minica](https://github.com/fopina/minica/releases/tag/v1.0.2-1) used to generate certs:

```
minica -ca-cert good-one.pem -ca-key good-one-key.pem -ca-cn "good-one" -domains '*.7f000001.nip.io'
minica -ca-cert good-one.pem -ca-key good-one-key.pem -domains 'good-client'
minica -ca-cert bad-one.pem -ca-key bad-one-key.pem -ca-cn "reject-me" -domains 'bad-client'
```

`docker compose up -d` to bring it up

## Validate server cert is valid against good-one CA - and that client cert is "optional"

```
$ curl --cacert good-one.pem \
       https://traefik.7f000001.nip.io:8889/dashboard/ 
<!DOCTYPE html><html><head><title>Traefik...

$ curl --cacert good-one.pem \
       https://whoami.7f000001.nip.io:8889/dashboard/ 
Hostname: c7461a3368d9
IP: 127.0.0.1
IP: ::1
...
```
