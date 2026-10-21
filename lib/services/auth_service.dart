import 'package:store_app/core/app_config.dart';
import 'package:store_app/helper/api.dart';

/// POST /auth/login  → returns a JWT token.
class AuthService {
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final data = await Api().post(
      url: '${AppConfig.baseUrl}/auth/login',
      body: {'username': username, 'password': password},
      Token: null,
    );
    return (data as Map<String, dynamic>)['token'] as String;
  }
}
