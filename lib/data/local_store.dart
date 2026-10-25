import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesStore implements LocalStore {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read() => _preferences.getString('befit.state.v1');

  @override
  Future<void> write(String value) =>
      _preferences.setString('befit.state.v1', value);
}

class MemoryStore implements LocalStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async => this.value = value;
}
