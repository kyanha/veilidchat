import 'dart:typed_data';

import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';

class InvitationGeneratorCubit extends FutureCubit<Uint8List> {
  InvitationGeneratorCubit(super.fut);
  InvitationGeneratorCubit.value(super.v) : super.value();
}
