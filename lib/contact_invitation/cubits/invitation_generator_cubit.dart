import 'dart:typed_data';

import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:veilid_support/veilid_support.dart';

class InvitationGeneratorCubit extends FutureCubit<(Uint8List, TypedKey)> {
  InvitationGeneratorCubit(super.fut);
  InvitationGeneratorCubit.value(super.v) : super.value();
}
