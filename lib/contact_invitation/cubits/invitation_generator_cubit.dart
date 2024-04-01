import 'dart:typed_data';

import 'package:bloc_tools/bloc_tools.dart';

class InvitationGeneratorCubit extends FutureCubit<Uint8List> {
  InvitationGeneratorCubit(super.fut);
  InvitationGeneratorCubit.value(super.v) : super.value();
}
