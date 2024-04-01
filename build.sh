#!/bin/bash
set -e

pushd packages/async_tools > /dev/null
./build.sh
popd > /dev/null

pushd packages/veilid_support > /dev/null
./build.sh
popd > /dev/null

dart run build_runner build --delete-conflicting-outputs

protoc --dart_out=lib/proto -I packages/veilid_support/lib/proto -I packages/veilid_support/lib/dht_support/proto -I lib/proto veilidchat.proto
sed -i '' 's/dht.pb.dart/package:veilid_support\/proto\/dht.pb.dart/g' lib/proto/veilidchat.pb.dart
sed -i '' 's/veilid.pb.dart/package:veilid_support\/proto\/veilid.pb.dart/g' lib/proto/veilidchat.pb.dart