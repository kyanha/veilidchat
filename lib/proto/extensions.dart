import 'dart:typed_data';

import 'package:veilid_support/veilid_support.dart';

import 'proto.dart' as proto;

proto.Message messageFromJson(Map<String, dynamic> j) =>
    proto.Message.create()..mergeFromJsonMap(j);

Map<String, dynamic> messageToJson(proto.Message m) => m.writeToJsonMap();

proto.ReconciledMessage reconciledMessageFromJson(Map<String, dynamic> j) =>
    proto.ReconciledMessage.create()..mergeFromJsonMap(j);

Map<String, dynamic> reconciledMessageToJson(proto.ReconciledMessage m) =>
    m.writeToJsonMap();

extension MessageExt on proto.Message {
  Uint8List get uniqueIdBytes {
    final author = this.author.toVeilid().decode();
    final id = this.id;
    return Uint8List.fromList([...author, ...id]);
  }

  String get uniqueIdString => base64UrlNoPadEncode(uniqueIdBytes);
}
