import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://blog-app-backend-bstb.onrender.com/api';
  static const String tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Saves the authentication token to local storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Retrieves the authentication token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Removes the authentication token from local storage
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  /// Helper to get common headers, including the auth token if available
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNo,
    required String email,
    required String password,
    required List<int> profilePhotoBytes,
    required String profilePhotoName,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    
    final request = http.MultipartRequest('POST', uri);
    
    // Add fields
    request.fields['full_name'] = fullName;
    request.fields['phone_no'] = phoneNo;
    request.fields['email'] = email;
    request.fields['password'] = password;
    
    // Add profile photo
    final multipartFile = http.MultipartFile.fromBytes(
      'profile_photo',
      profilePhotoBytes,
      filename: profilePhotoName,
    );
    
    request.files.add(multipartFile);
    
    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      
      // Extract and save token if registration is successful and token is provided
      if (jsonResponse['success'] == true && jsonResponse['token'] != null) {
        await saveToken(jsonResponse['token']);
      }
      
      return jsonResponse;
    } else {
      String errorMessage = 'Registration failed with status: ${response.statusCode}';
      try {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse['message'] != null) {
          errorMessage = errorResponse['message'];
        }
      } catch (e) {
        // ignore json parsing errors
      }
      throw Exception(errorMessage);
    }
  }

  /// Generic GET request wrapper
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  /// Generic POST request wrapper
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  /// Generic PUT request wrapper
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  /// Generic DELETE request wrapper
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  /// Login a user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['token'] != null) {
        await saveToken(jsonResponse['token']);
      }
      return jsonResponse;
    } else {
      String errorMessage = 'Login failed with status: ${response.statusCode}';
      try {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse['message'] != null) {
          errorMessage = errorResponse['message'];
        }
      } catch (e) {
        // ignore json parsing errors
      }
      throw Exception(errorMessage);
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await get('/auth/profile');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Failed to fetch profile with status: ${response.statusCode}';
      try {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse['message'] != null) {
          errorMessage = errorResponse['message'];
        }
      } catch (e) {
        // ignore json parsing errors
      }
      throw Exception(errorMessage);
    }
  }
}
