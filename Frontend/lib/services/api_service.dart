import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // For Android emulator

  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/auth/signup'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 405 ||
          response.statusCode == 200 ||
          response.statusCode == 404;
    } catch (e) {
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
      final requestBody = {
        'email': email,
        'password': password,
        'userType': userType.toLowerCase(),
        'profileData': profileData,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/signup'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Account created successfully',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? data['message'] ?? 'Signup failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Server error. Please try again later.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final requestBody = {'email': email, 'password': password};

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

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
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? data['message'] ?? 'Login failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Server error. Please try again later.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('profile_data');
  }

  static Future<Map<String, dynamic>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message':
              data['message'] ?? 'Password reset email sent successfully',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message':
              data['error'] ?? data['message'] ?? 'Failed to send reset email',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Server error. Please try again later.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/reset-password'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'token': token, 'newPassword': newPassword}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message':
              data['error'] ?? data['message'] ?? 'Failed to reset password',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Server error. Please try again later.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================
  // JOBS API METHODS
  // ============================

  static Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/jobs/$jobId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['job'] != null) {
          return {
            'success': true,
            'job': data['job'],
            'message': 'Job details fetched successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to fetch job details',
          };
        }
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Job not found'};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch job details',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Server error. Please try again later.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAllJobs({String? applicantId}) async {
    try {
      // Build URL properly - handle null case
      String url;
      if (applicantId != null && applicantId.isNotEmpty) {
        print("Fetching all jobs for applicant_id: $applicantId");
        url = '$baseUrl/api/alljobs/$applicantId';
      } else {
        print("Fetching all jobs without personalization");
        // Use a general jobs endpoint or the cvurl endpoint with 'null'
        url = '$baseUrl/api/alljobs/null'; // This will hit the cvurl route
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Handle both direct jobs array and nested structure
          final jobs = data['jobs'] ?? data['matches'] ?? [];
          return {
            'success': true,
            'jobs': jobs,
            'count': jobs.length,
            'message': 'Jobs fetched successfully',
            'source': data['source'], // 'gemini' or 'local'
            'scores': data['scores'], // matching scores if available
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to fetch jobs',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No jobs found',
          'jobs': [],
          'count': 0,
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch jobs',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'Server error. Please try again later.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Enhanced helper method with better error handling
  static Future<Map<String, dynamic>> getAllJobsWithStoredApplicant() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? profile;
    Map<String, dynamic>? user;

    try {
      final p = prefs.getString('profile_data');
      final u = prefs.getString('user_data');
      if (p != null) profile = json.decode(p);
      if (u != null) user = json.decode(u);
    } catch (_) {}

    final applicantId =
        (profile?['applicant_id'] ??
                profile?['id'] ??
                user?['applicant_id'] ??
                user?['user_id'] ??
                user?['id'])
            ?.toString();

    if (applicantId == null || applicantId.isEmpty) {
      return {
        'success': false,
        'message': 'Applicant ID not found. Please log in again.',
      };
    }
    print("Using applicant_id: $applicantId to fetch jobs");
    return getAllJobs(applicantId: applicantId);
  }

  static Future<Map<String, dynamic>> saveInternshipWithStoredApplicant({
    required String jobId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? profile;
    Map<String, dynamic>? user;

    try {
      final p = prefs.getString('profile_data');
      final u = prefs.getString('user_data');
      if (p != null) profile = json.decode(p);
      if (u != null) user = json.decode(u);
    } catch (_) {}

    final applicantId =
        (profile?['applicant_id'] ??
                profile?['id'] ??
                user?['applicant_id'] ??
                user?['user_id'] ??
                user?['id'])
            ?.toString();

    if (applicantId == null || applicantId.isEmpty) {
      return {
        'success': false,
        'message': 'Applicant ID not found. Please log in again.',
      };
    }

    return saveInternship(applicantId: applicantId, jobId: jobId);
  }

  static Future<Map<String, dynamic>> saveInternship({
    required String applicantId,
    required String jobId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/saved-internships'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: json.encode({'applicant_id': applicantId, 'job_id': jobId}),
          )
          .timeout(const Duration(seconds: 12));

      // Debug: print status code for save internship

      final data = response.body.isNotEmpty ? json.decode(response.body) : null;

      if (response.statusCode == 201) {
        return {
          'success': true,
          'savedInternship': data?['savedInternship'],
          'message': 'Internship saved',
        };
      }

      if (response.statusCode == 409) {
        return {
          'success': false,
          'code': 'ALREADY_SAVED',
          'message': (data?['error'] ?? 'Internship already saved').toString(),
        };
      }

      return {
        'success': false,
        'message': (data?['error'] ?? 'Failed to save internship').toString(),
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } on HttpException {
      return {'success': false, 'message': 'Server error'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid server response'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSavedInternships(
    String applicantId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // Attempt 1: path param
      final url1 = Uri.parse('$baseUrl/api/saved-internships/$applicantId');
      final resp1 = await http
          .get(url1, headers: headers)
          .timeout(const Duration(seconds: 12));

      http.Response useResp = resp1;

      // Fallback 2: snake_case query
      if (useResp.statusCode == 400 || useResp.statusCode == 404) {
        final url2 = Uri.parse(
          '$baseUrl/api/saved-internships?applicant_id=$applicantId',
        );
        final resp2 = await http
            .get(url2, headers: headers)
            .timeout(const Duration(seconds: 12));
        if (resp2.statusCode != 404) useResp = resp2;

        // Fallback 3: camelCase query
        if (useResp.statusCode == 400 || useResp.statusCode == 404) {
          final url3 = Uri.parse(
            '$baseUrl/api/saved-internships?applicantId=$applicantId',
          );
          final resp3 = await http
              .get(url3, headers: headers)
              .timeout(const Duration(seconds: 12));
          useResp = resp3;
        }
      }

      if (useResp.statusCode == 200) {
        final data = json.decode(useResp.body);

        List items = [];
        if (data['savedInternships'] is List) {
          items = data['savedInternships'];
        } else if (data['saved_internships'] is List) {
          items = data['saved_internships'];
        } else if (data['items'] is List) {
          items = data['items'];
        } else if (data['data'] is List) {
          items = data['data'];
        }

        final needsExpand = items.any(
          (e) => e is Map && e['job'] == null && e['job_id'] != null,
        );
        if (needsExpand) {
          final expanded = <Map<String, dynamic>>[];
          for (final it in items) {
            if (it is! Map) continue;
            final obj = Map<String, dynamic>.from(it);
            final jobId = it['job_id']?.toString();
            if (jobId != null && jobId.isNotEmpty) {
              final jr = await getJobById(jobId);
              if (jr['success'] == true && jr['job'] != null) {
                obj['job'] = jr['job'];
              }
            }
            expanded.add(obj);
          }
          return {'success': true, 'savedInternships': expanded};
        }

        return {'success': true, 'savedInternships': items};
      }

      if (useResp.statusCode == 404) {
        return {'success': true, 'savedInternships': []};
      }

      final err = useResp.body.isNotEmpty ? json.decode(useResp.body) : {};
      return {
        'success': false,
        'message': err['error'] ?? 'Failed to fetch saved internships',
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } on HttpException {
      return {'success': false, 'message': 'Server error'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid server response'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>>
  getSavedInternshipsWithStoredApplicant() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? profile;
    Map<String, dynamic>? user;

    try {
      final p = prefs.getString('profile_data');
      final u = prefs.getString('user_data');
      if (p != null) profile = json.decode(p);
      if (u != null) user = json.decode(u);
    } catch (_) {}

    final applicantId =
        (profile?['applicant_id'] ??
                profile?['id'] ??
                user?['applicant_id'] ??
                user?['user_id'] ??
                user?['id'])
            ?.toString();

    if (applicantId == null || applicantId.isEmpty) {
      return {
        'success': false,
        'message': 'Applicant ID not found. Please log in again.',
      };
    }

    return getSavedInternships(applicantId);
  }

  static Future<Map<String, dynamic>> submitApplication(
    Map<String, dynamic> payload,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final url = '$baseUrl/api/applications';
      final response = await http
          .post(Uri.parse(url), headers: headers, body: json.encode(payload))
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Application submitted successfully',
          'application': data['application'],
        };
      } else {
        return {
          'success': false,
          'error':
              data['error'] ??
              data['message'] ??
              'Failed to submit application',
          'status': response.statusCode,
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } on HttpException {
      return {'success': false, 'message': 'Server error'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid server response'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getApplications(
    String applicantId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final url = '$baseUrl/api/applications/$applicantId';
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      return data;
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } on HttpException {
      return {'success': false, 'message': 'Server error'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid server response'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getApplicationStats(
    String applicantId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final url = '$baseUrl/api/applications/$applicantId/stats';
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      return data;
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } on HttpException {
      return {'success': false, 'message': 'Server error'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid server response'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
