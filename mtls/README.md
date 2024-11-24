### Test traefik mTLS with CN filtering

Traefik supports mTLS but it does not allow filtering by CN per service, only at `tls.options` level.

While we could setup different `tls.options` entry per service, it is not very practical.

This benchmarks two approaches for CN filtering: `passTLSInfo + matchHeader` versus `custom plugin`

## Setup

[minica](https://github.com/fopina/minica/releases/tag/v1.0.2-1) used to generate certs:

```
minica -ca-cert good-one.pem -ca-key good-one-key.pem -ca-cn "good-one" -domains '*.7f000001.nip.io'
minica -ca-cert good-one.pem -ca-key good-one-key.pem -domains 'good-client'
minica -ca-cert good-one.pem -ca-key good-one-key.pem -domains 'good-client-2'
minica -ca-cert good-one.pem -ca-key good-one-key.pem -domains 'good-client-bad-cn'
minica -ca-cert bad-one.pem -ca-key bad-one-key.pem -ca-cn "reject-me" -domains 'bad-client'
```

`docker compose up -d` to bring this up. All host matching done with `7f000001.nip.io` so they resolve to `127.0.0.1`.

## Validate server cert is valid against good-one CA - and that client cert is "optional"

```
$ ./test_it.bats

test_it.bats
 ✓ test without mtls succeeds
 ✓ test mtls without cert is rejected
 ✓ test mtls with bad-client cert is rejected
 ✓ test mtls with good-client cert succeeds

4 tests, 0 failures
```

`whoami` used to validate headers, `nginx` to benchmark different mTLS approaches, as it replies 3x faster than whoami and easier to notice differences

```
$ bombardier -n 10000 https://whoami.7f000001.nip.io:8889 -k   
Statistics        Avg      Stdev        Max
  Reqs/sec      2094.29     721.82    3572.05
  Latency       59.42ms    67.24ms   739.37ms
  HTTP codes:
    1xx - 0, 2xx - 10000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     1.25MB/s

$ bombardier -n 10000 https://nginx.7f000001.nip.io:8889 -k
Statistics        Avg      Stdev        Max
  Reqs/sec      3377.25    1823.16    8917.36
  Latency       37.00ms    31.47ms   333.36ms
  HTTP codes:
    1xx - 0, 2xx - 10000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     3.10MB/s
```
