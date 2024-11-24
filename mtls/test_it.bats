#!/usr/bin/env bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'

@test "test without mtls" {
  run curl -f \
           --cacert good-one.pem \
           https://nginx.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test mtls without cert" {
  run curl -f \
           --cacert good-one.pem \
           https://nginx-mtls.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test mtls with bad-client cert" {
  run curl -f \
           --cacert good-one.pem \
           --cert bad-client/cert.pem \
           --key bad-client/key.pem \
           https://nginx-mtls.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test mtls with good-client cert" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client/cert.pem \
           --key good-client/key.pem \
           https://nginx-mtls.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}
