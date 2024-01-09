import '../tools/tools.dart';
import 'settings.dart';

xxx convert to non-asyncvalue based wrapper since there's always a default here

class PreferencesCubit extends StreamWrapperCubit<Preferences> {
  PreferencesCubit(PreferencesRepository repository)
      : super(repository.stream, defaultState: repository.value);
}
