import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = 'http://192.168.41.220:5000'; // For Android emulator


  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing connection to: $baseUrl/api/auth/signup');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      print('🔍 Test response status: ${response.statusCode}');
      print('🔍 Test response body: ${response.body}');
      
      return response.statusCode == 405 || response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return json.decode(userDataString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileDataString = prefs.getString('profile_data');
      if (profileDataString != null) {
        return json.decode(profileDataString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String userType,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      print('🚀 Attempting signup to: $baseUrl/api/auth/signup');
      
      final requestBody = {
        'email': email,
        'password': password,
        'userType': userType.toLowerCase(), 
        'profileData': profileData,
      };
      
      print('📤 Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('📥 Signup response status: ${response.statusCode}');
      print('📥 Signup response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true, 
          'message': data['message'] ?? 'Account created successfully'
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false, 
          'message': data['error'] ?? data['message'] ?? 'Signup failed'
        };
      }
    } on SocketException {
      return {
        'success': false, 
        'message': 'No internet connection. Please check your network.'
      };
    } on HttpException {
      return {
        'success': false, 
        'message': 'Server error. Please try again later.'
      };
    } on FormatException {
      return {
        'success': false, 
        'message': 'Invalid response format from server.'
      };
    } catch (e) {
      print('❌ Signup error: $e');
      return {
        'success': false, 
        'message': 'Network error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Attempting login to: $baseUrl/api/auth/login');
      
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      print('📤 Login request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('📥 Login response status: ${response.statusCode}');
      print('📥 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString('auth_token', data['token']);
        }
        if (data['user'] != null) {
          await prefs.setString('user_data', json.encode(data['user']));
        }
        if (data['profile'] != null) {
          await prefs.setString('profile_data', json.encode(data['profile']));
        }

        return {
          'success': true, 
          'user': data['user'],
          'profile': data['profile'],
          'message': data['message'] ?? 'Login successful'
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false, 
          'message': data['error'] ?? data['message'] ?? 'Login failed'
        };
      }
    } on SocketException {
      return {
        'success': false, 
        'message': 'No internet connection. Please check your network.'
      };
    } on HttpException {
      return {
        'success': false, 
        'message': 'Server error. Please try again later.'
      };
    } on FormatException {
      return {
        'success': false, 
        'message': 'Invalid response format from server.'
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false, 
        'message': 'Network error: $e'
      };
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('profile_data');
  }
}