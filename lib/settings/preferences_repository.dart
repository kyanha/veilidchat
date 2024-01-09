import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../tools/tools.dart';
import 'models/models.dart';

class PreferencesRepository {
  PreferencesRepository._();

  late final SharedPreferencesValue<Preferences> _data;

  Preferences get value => _data.requireValue;
  Stream<Preferences> get stream => _data.stream;

  //////////////////////////////////////////////////////////////
  /// Singleton initialization

  static PreferencesRepository instance = PreferencesRepository._();

  Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    _data = SharedPreferencesValue<Preferences>(
        sharedPreferences: sharedPreferences,
        keyName: 'preferences',
        valueFromJson: (obj) =>
            obj != null ? Preferences.fromJson(obj) : Preferences.defaults,
        valueToJson: (val) => val.toJson());
    await _data.get();
  }

  Future<void> set(Preferences value) => _data.set(value);
  Future<Preferences> get() => _data.get();
}
