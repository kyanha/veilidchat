import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';

import 'settings.dart';

class PreferencesCubit extends StreamWrapperCubit<Preferences> {
  PreferencesCubit(PreferencesRepository repository)
      : super(repository.stream, defaultState: repository.value);
}
