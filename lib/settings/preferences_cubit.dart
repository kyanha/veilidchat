import '../tools/tools.dart';
import 'settings.dart';

class PreferencesCubit extends StreamWrapperCubit<Preferences> {
  PreferencesCubit(PreferencesRepository repository)
      : super(repository.stream, defaultState: repository.value);
}
