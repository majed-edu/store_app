import 'package:store_app/core/app_config.dart';
import 'package:store_app/helper/api.dart';
import 'package:store_app/models/user_model.dart';

class UsersService {
  AppUser _toUser(Map<String, dynamic> json) {
    return AppUser.fromApi(json, role: UserRole.customer);
  }

  /// GET /users
  Future<List<AppUser>> getAllUsers() async {
    final data =
        await Api().get(url: '${AppConfig.baseUrl}/users') as List<dynamic>;
    return data.map((json) => _toUser(json as Map<String, dynamic>)).toList();
  }

  /// GET /users/:id
  Future<AppUser> getUser(int id) async {
    final data = await Api().get(url: '${AppConfig.baseUrl}/users/$id');
    return _toUser(data as Map<String, dynamic>);
  }

  Future<dynamic> createUser({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    return Api().post(
      url: '${AppConfig.baseUrl}/users',
      body: {
        'email': email,
        'username': username,
        'password': password,
        'firstname': firstName,
        'lastname': lastName,
        'phone': phone,
      },
      Token: null,
    );
  }
}
