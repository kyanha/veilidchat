import 'package:veilid_support/veilid_support.dart';

import '../../../proto/proto.dart' as proto;

class AuthorInputSource {
  AuthorInputSource({required this.messages, required this.cubit});

  final DHTLogStateData<proto.Message> messages;
  final DHTLogCubit<proto.Message> cubit;
}
