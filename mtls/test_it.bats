#!/usr/bin/env bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'

@test "test without mtls succeeds" {
  run curl -f \
           --cacert good-one.pem \
           https://nginx.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls without cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           https://nginx-mtls.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test mtls with bad-client cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert bad-client/cert.pem \
           --key bad-client/key.pem \
           https://nginx-mtls.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test mtls with good-client cert succeeds" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client/cert.pem \
           --key good-client/key.pem \
           https://nginx-mtls.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls with good-client-bad-cn cert succeeds" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client-bad-cn/cert.pem \
           --key good-client-bad-cn/key.pem \
           https://nginx-mtls.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls-cn without cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           https://nginx-mtls-cn.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test mtls-cn with bad-client cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert bad-client/cert.pem \
           --key bad-client/key.pem \
           https://nginx-mtls-cn.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test mtls-cn with good-client cert succeeds" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client/cert.pem \
           --key good-client/key.pem \
           https://nginx-mtls-cn.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls-cn with good-client-bad-cn cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client-bad-cn/cert.pem \
           --key good-client-bad-cn/key.pem \
           https://nginx-mtls-cn.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'returned error: 403'
}

@test "test mtls-cn-plugin with bad-client cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert bad-client/cert.pem \
           --key bad-client/key.pem \
           https://nginx-mtls-cn-plugin.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test mtls-cn-plugin with good-client cert succeeds" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client/cert.pem \
           --key good-client/key.pem \
           https://nginx-mtls-cn-plugin.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls-cn-plugin with good-client-bad-cn cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client-bad-cn/cert.pem \
           --key good-client-bad-cn/key.pem \
           https://nginx-mtls-cn-plugin.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'returned error: 403'
}

@test "test mtls-cn-final with good-client cert succeeds" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client/cert.pem \
           --key good-client/key.pem \
           https://nginx-mtls-cn-final.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls-cn-final with good-client-bad-cn cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client-bad-cn/cert.pem \
           --key good-client-bad-cn/key.pem \
           https://nginx-mtls-cn-final.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'returned error: 403'
}

@test "test mtls-cn-plugin-final with good-client cert succeeds" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client/cert.pem \
           --key good-client/key.pem \
           https://nginx-mtls-cn-plugin-final.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls-cn-plugin-final with good-client-bad-cn cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client-bad-cn/cert.pem \
           --key good-client-bad-cn/key.pem \
           https://nginx-mtls-cn-plugin-final.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'returned error: 403'
}