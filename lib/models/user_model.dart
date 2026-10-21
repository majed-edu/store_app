import 'package:store_app/core/formatters.dart';

enum UserRole { customer, merchant }

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.street,
    required this.city,
    required this.role,
    this.isLocal = false,
  });

  final int id;
  final String username, email, firstName, lastName, phone, street, city;
  final UserRole role;

  /// True when the account was created inside the app.
  final bool isLocal;

  String get fullName =>
      '${Formatters.titleCase(firstName)} ${Formatters.titleCase(lastName)}'
          .trim();

  String get displayFirstName =>
      firstName.isEmpty ? username : Formatters.titleCase(firstName);

  String get initials {
    final first = firstName.isEmpty ? '' : firstName[0];
    final last = lastName.isEmpty ? '' : lastName[0];
    final value = '$first$last'.toUpperCase();
    return value.isEmpty ? username[0].toUpperCase() : value;
  }

  String get address => [street, city]
      .where((part) => part.trim().isNotEmpty)
      .map(Formatters.titleCase)
      .join(', ');

  AppUser copyWith({String? phone, String? street, String? city}) {
    return AppUser(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      role: role,
      isLocal: isLocal,
    );
  }

  factory AppUser.fromApi(Map<String, dynamic> json, {required UserRole role}) {
    final name =
        (json['name'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final address =
        (json['address'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final street = '${address['number'] ?? ''} ${address['street'] ?? ''}'
        .trim();

    return AppUser(
      id: json['id'] as int,
      username: json['username'].toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (name['firstname'] ?? '').toString(),
      lastName: (name['lastname'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      street: street,
      city: (address['city'] ?? '').toString(),
      role: role,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'street': street,
    'city': city,
    'role': role.name,
    'isLocal': isLocal,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      role: UserRole.values.byName(json['role'] as String),
      isLocal: json['isLocal'] as bool? ?? false,
    );
  }
}
