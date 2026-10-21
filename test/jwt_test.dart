import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/jwt.dart';

String _token(Map<String, dynamic> payload) {
  String part(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part(payload)}.signature';
}

void main() {
  test('reads the user id from the sub field', () {
    expect(Jwt.userId(_token({'sub': 2, 'user': 'mor_2314'})), 2);
  });

  test('returns null for something that is not a token', () {
    expect(Jwt.userId('hello'), isNull);
    expect(Jwt.userId('a.b.c'), isNull);
  });
}
