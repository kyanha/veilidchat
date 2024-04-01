@echo off
dart run build_runner build --delete-conflicting-outputs

pushd packages\async_tools
call build.bat
popd 
pushd packages\veilid_support
call build.bat
popd 

pushd lib
protoc --dart_out=proto -I veilid_support\proto -I veilid_support\dht_support\proto -I proto veilidchat.proto
protoc --dart_out=proto -I veilid_support\proto -I veilid_support\dht_support\proto dht.proto
protoc --dart_out=proto -I veilid_support\proto veilid.proto
popd
