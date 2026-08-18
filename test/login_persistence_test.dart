import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hism_management_system/services/remember_me_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Remember me storage', () {
    test('saves and loads credentials when enabled', () async {
      await RememberMeStorage.saveCredentials(
        email: 'admin@example.com',
        password: 'secret123',
        rememberMe: true,
      );

      final loaded = await RememberMeStorage.loadCredentials();

      expect(loaded['email'], 'admin@example.com');
      expect(loaded['password'], 'secret123');
      expect(await RememberMeStorage.isRememberMeEnabled(), isTrue);
    });

    test('clears saved credentials when logout is triggered', () async {
      await RememberMeStorage.saveCredentials(
        email: 'teacher@example.com',
        password: 'pass456',
        rememberMe: true,
      );

      await RememberMeStorage.clearCredentials();

      final loaded = await RememberMeStorage.loadCredentials();
      expect(loaded['email'], isNull);
      expect(loaded['password'], isNull);
      expect(await RememberMeStorage.isRememberMeEnabled(), isFalse);
    });
  });
}
