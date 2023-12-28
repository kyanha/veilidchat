#!/bin/bash
set -e
dart run build_runner build --delete-conflicting-outputs

pushd lib > /dev/null
protoc --dart_out=proto -I ../packages/veilid_support/lib/proto -I ../packages/veilid_support/lib/dht_support/proto -I proto veilidchat.proto
popd > /dev/null
