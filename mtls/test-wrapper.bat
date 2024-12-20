#!/usr/bin/env bats

load '../test/test_helper/bats-support/load'
load '../test/test_helper/bats-assert/load'

@test "test nginx is running" {
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

@test "wrapper test" {
    final_status=0
    BACKENDS=(nginx-mtls-cn nginx-mtls-cn-plugin nginx-mtls-cn-final nginx-mtls-cn-plugin-final)

    for b in "${BACKENDS[@]}"; do
        backend="$b" run bats -t tests.bats
        echo "# $output" >&3
        echo "#" >&3
        final_status=$(($final_status + $status))
    done

    [ "$final_status" -eq 0 ]
}