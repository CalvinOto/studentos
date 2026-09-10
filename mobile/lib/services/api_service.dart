import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thrown for any non-2xx response other than 401.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Thrown specifically for 401s, so the app can distinguish
/// "your token is invalid/expired, please log in again" from
/// any other kind of failure.
class ApiUnauthorizedException extends ApiException {
  ApiUnauthorizedException() : super('Session expired. Please log in again.');
}

class ApiService {
  
  //http://localhost:3000
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'studentos_token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<void> _saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  static Future<void> logout() => _storage.delete(key: _tokenKey);

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void _checkOk(http.Response res) {
    if (res.statusCode == 401) throw ApiUnauthorizedException();
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Request failed (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] != null) {
          final m = body['message'];
          message = m is List ? m.join(', ') : m.toString();
        }
      } catch (_) {
        // response wasn't JSON — keep the generic message
      }
      throw ApiException(message);
    }
  }

  // ---- auth ----

  static Future<void> register(String email, String password, String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    _checkOk(res);
    final data = jsonDecode(res.body);
    await _saveToken(data['accessToken']);
  }

  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _checkOk(res);
    final data = jsonDecode(res.body);
    await _saveToken(data['accessToken']);
  }

  // ---- profile (also covers budget + theme, per the backend's design) ----

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(Uri.parse('$baseUrl/profile'), headers: await _headers());
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> patch) async {
    final res = await http.patch(Uri.parse('$baseUrl/profile'), headers: await _headers(), body: jsonEncode(patch));
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ---- classes ----

  static Future<List<dynamic>> getClasses() async {
    final res = await http.get(Uri.parse('$baseUrl/classes'), headers: await _headers());
    _checkOk(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createClass(Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl/classes'), headers: await _headers(), body: jsonEncode(body));
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateClass(String id, Map<String, dynamic> body) async {
    final res = await http.patch(Uri.parse('$baseUrl/classes/$id'), headers: await _headers(), body: jsonEncode(body));
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> deleteClass(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/classes/$id'), headers: await _headers());
    _checkOk(res);
  }

  // ---- tasks ----

  static Future<List<dynamic>> getTasks() async {
    final res = await http.get(Uri.parse('$baseUrl/tasks'), headers: await _headers());
    _checkOk(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl/tasks'), headers: await _headers(), body: jsonEncode(body));
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateTask(String id, Map<String, dynamic> body) async {
    final res = await http.patch(Uri.parse('$baseUrl/tasks/$id'), headers: await _headers(), body: jsonEncode(body));
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> toggleTask(String id) async {
    final res = await http.patch(Uri.parse('$baseUrl/tasks/$id/toggle'), headers: await _headers());
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> deleteTask(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/tasks/$id'), headers: await _headers());
    _checkOk(res);
  }

  // ---- expenses ----

  static Future<List<dynamic>> getExpenses() async {
    final res = await http.get(Uri.parse('$baseUrl/expenses'), headers: await _headers());
    _checkOk(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createExpense(Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl/expenses'), headers: await _headers(), body: jsonEncode(body));
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateExpense(String id, Map<String, dynamic> body) async {
    final res = await http.patch(Uri.parse('$baseUrl/expenses/$id'), headers: await _headers(), body: jsonEncode(body));
    _checkOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> deleteExpense(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/expenses/$id'), headers: await _headers());
    _checkOk(res);
  }
}
