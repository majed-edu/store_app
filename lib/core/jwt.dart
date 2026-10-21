import 'dart:convert';

class Jwt {
  static Map<String, dynamic>? payload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(json);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  static int? userId(String token) {
    final sub = payload(token)?['sub'];
    if (sub is int) return sub;
    return int.tryParse('$sub');
  }
}
