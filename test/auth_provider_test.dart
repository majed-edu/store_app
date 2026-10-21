import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/services/users_service.dart';
import 'package:store_app/storage/local_store.dart';

class _FakeUsersService extends UsersService {
  @override
  Future<dynamic> createUser({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async => {'id': 21};
}

void main() {
  late LocalStore store;
  late AuthProvider auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await LocalStore.open();
    auth = AuthProvider(store, usersService: _FakeUsersService());
  });

  Future<void> register({
    String username = 'sara',
    UserRole role = UserRole.customer,
  }) {
    return auth.register(
      firstName: 'Sara',
      lastName: 'Ali',
      email: 'sara@example.com',
      username: username,
      phone: '0500000000',
      password: 'secret1',
      role: role,
    );
  }

  test('register logs the user in with the chosen role', () async {
    await register(role: UserRole.merchant);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.isMerchant, isTrue);
    expect(auth.user!.id, greaterThanOrEqualTo(1000));
  });

  test('the same username cannot be used twice', () async {
    await register();
    expect(register(), throwsA(isA<AuthException>()));
  });

  test('local account logs in with the right password only', () async {
    await register();
    await auth.logout();
    expect(auth.isLoggedIn, isFalse);

    await expectLater(
      auth.login(username: 'sara', password: 'wrong'),
      throwsA(isA<AuthException>()),
    );
    await auth.login(username: 'SARA', password: 'secret1');
    expect(auth.user!.username, 'sara');
  });

  test('the password is not stored as plain text', () async {
    await register();
    expect(store.read('accounts'), isNot(contains('secret1')));
  });

  test('session survives a restart, and profile edits are kept', () async {
    await register();
    await auth.updateProfile(phone: '055', street: '1 Main St', city: 'riyadh');

    final restarted = AuthProvider(store, usersService: _FakeUsersService());
    await restarted.restore();
    expect(restarted.user!.username, 'sara');
    expect(restarted.user!.address, '1 Main St, Riyadh');
  });
}
