import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when the server answers with a non-2xx status code.
class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}

/// Same methods and parameters as before, plus:
/// - `delete`
/// - `post(asJson: true)` for bodies that contain lists (like a cart)
/// - errors are [ApiException]s with the status code, and a plain-text error body no longer crashes
/// - the token is no longer printed in the console
class Api {
  // ##############################################################
  // GET
  // ###############################################################
  Future<dynamic> get({required String url, String? token}) async {
    final response = await http.get(Uri.parse(url), headers: _headers(token));
    return _handle(response);
  }

  // ##############################################################
  // POST
  // ###############################################################
  Future<dynamic> post({
    required String url,
    required dynamic body,
    required String? Token,
    bool asJson = false,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      body: asJson ? jsonEncode(body) : body,
      headers: _headers(Token, json: asJson),
    );
    return _handle(response);
  }

  // ##############################################################
  // PUT
  // ###############################################################
  Future<dynamic> put({
    required String url,
    required dynamic body,
    required String? Token,
  }) async {
    final response = await http.put(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        ..._headers(Token),
      },
    );
    return _handle(response);
  }

  // ##############################################################
  // DELETE
  // ###############################################################
  Future<dynamic> delete({required String url, String? Token}) async {
    final response = await http.delete(Uri.parse(url), headers: _headers(Token));
    return _handle(response);
  }

  // ----------------------------------------------------------------

  Map<String, String> _headers(String? token, {bool json = false}) {
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _handle(http.Response response) {
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok) throw ApiException(response.statusCode, response.body);
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }
}
