import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:store_app/core/app_config.dart';
import 'package:store_app/core/app_logger.dart';
import 'package:store_app/core/jwt.dart';
import 'package:store_app/helper/api.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/services/auth_service.dart';
import 'package:store_app/services/users_service.dart';
import 'package:store_app/storage/local_store.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._store, {
    AuthService? authService,
    UsersService? usersService,
  }) : _authService = authService ?? AuthService(),
       _usersService = usersService ?? UsersService();

  static const _sessionKey = 'session';
  static const _accountsKey = 'accounts';
  static const _profilesKey = 'profiles';

  final LocalStore _store;
  final AuthService _authService;
  final UsersService _usersService;

  AppUser? _user;
  String? _token;
  bool _isRestoring = true;

  AppUser? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null;
  bool get isRestoring => _isRestoring;
  bool get isMerchant => _user?.role == UserRole.merchant;

  // ------------------------------------------------------------ session

  /// Called once when the app starts: brings back the previous session.
  Future<void> restore() async {
    final raw = _store.read(_sessionKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _token = map['token'] as String;
        _user = _withProfile(
          AppUser.fromJson(map['user'] as Map<String, dynamic>),
        );
        AppLog.info(
          'AUTH',
          'session restored for @${_user!.username} (${_user!.role.name})',
        );
      } catch (_) {
        await _store.remove(_sessionKey);
      }
    }
    _isRestoring = false;
    notifyListeners();
  }

  Future<void> _startSession(AppUser user, String token) async {
    _user = _withProfile(user);
    _token = token;
    await _saveSession();
    AppLog.info('AUTH', 'logged in as @${user.username} (${user.role.name})');
    notifyListeners();
  }

  Future<void> _saveSession() {
    return _store.write(
      _sessionKey,
      jsonEncode({'token': _token, 'user': _user!.toJson()}),
    );
  }

  Future<void> logout() async {
    AppLog.info('AUTH', 'logged out @${_user?.username}');
    _user = null;
    _token = null;
    await _store.remove(_sessionKey);
    notifyListeners();
  }

  // -------------------------------------------------------------- login

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final name = username.trim();

    final local = _findLocalAccount(name);
    if (local != null) {
      if (local.hash != _hash(name, password)) {
        throw const AuthException('Incorrect username or password.');
      }
      await _startSession(local.user, 'local-${local.user.id}');
      return;
    }

    try {
      final token = await AppLog.run(
        'Login "$name"',
        () => _authService.login(username: name, password: password),
      );
      final id = Jwt.userId(token);
      if (id == null) {
        throw const AuthException(
          'The server sent an unexpected answer. Try again.',
        );
      }
      final user = await AppLog.run(
        'Load profile #$id',
        () => _usersService.getUser(id),
        onSuccess: (u) => '${u.fullName} (${u.role.name})',
      );
      await _startSession(user, token);
    } on AuthException {
      rethrow;
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 401) {
        throw const AuthException('Incorrect username or password.');
      }
      throw AuthException(
        'The server had a problem (${e.statusCode}). Try again later.',
      );
    } catch (_) {
      throw const AuthException(
        "Can't reach the server. Check your connection and try again.",
      );
    }
  }

  // ----------------------------------------------------------- register

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final name = username.trim();
    if (_findLocalAccount(name) != null) {
      throw const AuthException('That username is already taken.');
    }

    try {
      await AppLog.run(
        'Create account "$name"',
        () => _usersService.createUser(
          email: email.trim(),
          username: name,
          password: password,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          phone: phone.trim(),
        ),
        onSuccess: (r) => 'server answered $r',
      );
    } catch (_) {
      throw const AuthException(
        "Can't reach the server. Check your connection and try again.",
      );
    }

    final accounts = _readAccounts();
    final user = AppUser(
      id: AppConfig.localIdStart + accounts.length,
      username: name,
      email: email.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
      street: '',
      city: '',
      role: role,
      isLocal: true,
    );
    accounts.add(_Account(user: user, hash: _hash(name, password)));
    await _store.write(
      _accountsKey,
      jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
    await _startSession(user, 'local-${user.id}');
  }

  // ------------------------------------------------------------ profile

  Future<void> updateProfile({
    required String phone,
    required String street,
    required String city,
  }) async {
    final current = _user;
    if (current == null) return;

    final profiles = _readProfiles();
    profiles['${current.id}'] = {
      'phone': phone,
      'street': street,
      'city': city,
    };
    await _store.write(_profilesKey, jsonEncode(profiles));

    _user = current.copyWith(phone: phone, street: street, city: city);
    await _saveSession();
    AppLog.info('AUTH', 'profile updated for @${current.username}');
    notifyListeners();
  }

  AppUser _withProfile(AppUser user) {
    final saved = _readProfiles()['${user.id}'];
    if (saved == null) return user;
    return user.copyWith(
      phone: saved['phone'] as String?,
      street: saved['street'] as String?,
      city: saved['city'] as String?,
    );
  }

  Map<String, dynamic> _readProfiles() {
    final raw = _store.read(_profilesKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  // ----------------------------------------------------- local accounts

  List<_Account> _readAccounts() {
    final raw = _store.read(_accountsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => _Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  _Account? _findLocalAccount(String username) {
    for (final account in _readAccounts()) {
      if (account.user.username.toLowerCase() == username.toLowerCase()) {
        return account;
      }
    }
    return null;
  }

  String _hash(String username, String password) {
    return sha256
        .convert(utf8.encode('${username.toLowerCase()}:$password'))
        .toString();
  }
}

class _Account {
  const _Account({required this.user, required this.hash});

  final AppUser user;
  final String hash;

  Map<String, dynamic> toJson() => {'user': user.toJson(), 'hash': hash};

  factory _Account.fromJson(Map<String, dynamic> json) => _Account(
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    hash: json['hash'] as String,
  );
}
