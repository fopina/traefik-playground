#!/usr/bin/env bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'

@test "test $backend without cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           https://$backend.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test $backend with bad-client cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert bad-client/cert.pem \
           --key bad-client/key.pem \
           https://$backend.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'alert bad certificate, errno 0'
}

@test "test $backend with good-client cert succeeds" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client/cert.pem \
           --key good-client/key.pem \
           https://$backend.7f000001.nip.io:8889/
  assert_success
  assert_output --partial 'Thank you for using nginx.'
}

@test "test $backend with good-client-bad-cn cert is rejected" {
  run curl -f \
           --cacert good-one.pem \
           --cert good-client-bad-cn/cert.pem \
           --key good-client-bad-cn/key.pem \
           https://$backend.7f000001.nip.io:8889/
  assert_failure 56
  assert_output --partial 'returned error: 403'
}