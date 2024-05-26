import 'proto.dart' as proto;

proto.Message messageFromJson(Map<String, dynamic> j) =>
    proto.Message.create()..mergeFromJsonMap(j);

Map<String, dynamic> messageToJson(proto.Message m) => m.writeToJsonMap();

proto.ReconciledMessage reconciledMessageFromJson(Map<String, dynamic> j) =>
    proto.ReconciledMessage.create()..mergeFromJsonMap(j);

Map<String, dynamic> reconciledMessageToJson(proto.ReconciledMessage m) =>
    m.writeToJsonMap();
