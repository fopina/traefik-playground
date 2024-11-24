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
$ bombardier -n 10000 https://whoami.7f000001.nip.io:8889 -k -l
Statistics        Avg      Stdev        Max
  Reqs/sec      2104.09     586.39    3328.22
  Latency       59.01ms    64.34ms   549.66ms
  Latency Distribution
     ...
     99%   289.36ms
  HTTP codes:
    1xx - 0, 2xx - 10000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     1.26MB/s

$ bombardier -n 10000 https://nginx.7f000001.nip.io:8889 -k
Statistics        Avg      Stdev        Max
  Reqs/sec      3714.36    1533.58    8782.58
  Latency       33.85ms    24.08ms   355.87ms
  Latency Distribution
     ...
     99%   128.62ms
  HTTP codes:
    1xx - 0, 2xx - 10000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     3.39MB/s
```

Benchmark mTLS enabled (no CN validation)

```
$ bombardier -n 10000 https://nginx-mtls.7f000001.nip.io:8889 -k --cert good-client/cert.pem --key good-client/key.pem -l
Statistics        Avg      Stdev        Max
  Reqs/sec      4131.03    1781.56    8998.69
  Latency       30.31ms    28.63ms   424.95ms
  Latency Distribution
     ...
     99%   142.07ms
  HTTP codes:
    1xx - 0, 2xx - 10000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     3.86MB/s
```

Benchmark mTLS enabled and CN validated via forward-auth

```
$ bombardier -n 10000 https://nginx-mtls-cn.7f000001.nip.io:8889 -k --cert good-client/cert.pem --key good-client/key.pem -l
Statistics        Avg      Stdev        Max
  Reqs/sec      1089.06     762.40    4946.31
  Latency      114.34ms    71.01ms   716.47ms
  Latency Distribution
     ...
     99%   371.55ms
  HTTP codes:
    1xx - 0, 2xx - 10000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     1.02MB/s
```

Benchmark mTLS enabled and CN validated via custom plugin

```
$ bombardier -n 10000 https://nginx-mtls-cn-plugin.7f000001.nip.io:8889 -k --cert good-client/cert.pem --key good-client/key.pem -l
Statistics        Avg      Stdev        Max
  Reqs/sec      3259.70    1410.83    6955.92
  Latency       38.20ms    37.13ms   588.97ms
  Latency Distribution
     ...
     99%   227.25ms
  HTTP codes:
    1xx - 0, 2xx - 10000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     3.09MB/s
```