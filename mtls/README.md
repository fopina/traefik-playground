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

nginx to benchmark different mTLS approaches, as it's lighter than whoami and easier to notice differences

```
$ hey -n 10000 https://whoami.7f000001.nip.io:8889

Summary:
  Total:	6.0751 secs
  Slowest:	0.2403 secs
  Fastest:	0.0020 secs
  Average:	0.0292 secs
  Requests/sec:	1646.0758

Latency distribution:
  95% in 0.0807 secs
  99% in 0.1178 secs
```

```
$ hey -n 10000 https://nginx.7f000001.nip.io:8889

Summary:
  Total:	2.4200 secs
  Slowest:	0.1835 secs
  Fastest:	0.0018 secs
  Average:	0.0119 secs
  Requests/sec:	4132.2788

Latency distribution:
  95% in 0.0247 secs
  99% in 0.0578 secs
```
