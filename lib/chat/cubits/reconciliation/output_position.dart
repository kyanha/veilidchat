import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../proto/proto.dart' as proto;

@immutable
class OutputPosition extends Equatable {
  const OutputPosition(this.message, this.pos);
  final proto.Message message;
  final int pos;
  @override
  List<Object?> get props => [message, pos];
}
