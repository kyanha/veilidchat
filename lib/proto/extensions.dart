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
  Uint8List get idBytes => Uint8List.fromList(id);

  Uint8List get authorUniqueIdBytes {
    final author = this.author.toVeilid().decode();
    final id = this.id;
    return Uint8List.fromList([...author, ...id]);
  }

  String get authorUniqueIdString => base64UrlNoPadEncode(authorUniqueIdBytes);

  static int compareTimestamp(proto.Message a, proto.Message b) =>
      a.timestamp.compareTo(b.timestamp);
}

extension ContactExt on proto.Contact {
  String get displayName =>
      nickname.isNotEmpty ? '$nickname (${profile.name})' : profile.name;
}

extension ChatExt on proto.Chat {
  TypedKey get localConversationRecordKey {
    switch (whichKind()) {
      case proto.Chat_Kind.direct:
        return direct.localConversationRecordKey.toVeilid();
      case proto.Chat_Kind.group:
        return group.localConversationRecordKey.toVeilid();
      case proto.Chat_Kind.notSet:
        throw StateError('unknown chat kind');
    }
  }
}
