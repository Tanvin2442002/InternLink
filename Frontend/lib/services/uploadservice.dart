import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class UploadService {
  // Validate CV content using Gemini AI
  static Future<Map<String, dynamic>> validateCvContent({
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return {'success': false, 'message': 'File not found'};
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final base = ApiService.baseUrl;
      final uri = Uri.parse('$base/api/validate-cv');

      final req = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      req.headers['Accept'] = 'application/json';

      req.files.add(await http.MultipartFile.fromPath(
        'cv',
        filePath,
        contentType: MediaType('application', 'pdf'),
      ));

      try {
        final streamed = await req.send().timeout(const Duration(seconds: 30));
        final resp = await http.Response.fromStream(streamed);
        final raw = resp.body;
        final ctype = resp.headers['content-type'] ?? '';
        Map<String, dynamic> body = {};
        
        if (raw.isNotEmpty && (ctype.contains('application/json') || raw.trim().startsWith('{') || raw.trim().startsWith('['))) {
          try {
            final decoded = json.decode(raw);
            if (decoded is Map<String, dynamic>) body = decoded;
          } catch (_) {
            // leave body as {}
          }
        }

        print('[UploadService] CV Validation POST $uri -> ${resp.statusCode}');

        if (resp.statusCode == 200) {
          return {
            'success': body['isValidCv'] == true,
            'message': body['message'] ?? (body['isValidCv'] == true ? 'Valid CV' : 'Not a valid CV'),
            'details': body['details'],
          };
        } else {
          return {
            'success': false,
            'message': body['error'] ?? body['message'] ?? 'CV validation failed',
          };
        }
      } on SocketException {
        return {'success': false, 'message': 'No internet connection'};
      } on TimeoutException {
        return {'success': false, 'message': 'CV validation timed out'};
      } catch (e) {
        return {'success': false, 'message': 'Network error: $e'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to validate CV: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadCvFile({
    required String filePath,
    String? applicantIdOverride,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Map<String, dynamic>? profile;
      Map<String, dynamic>? user;
      try {
        final p = prefs.getString('profile_data');
        final u = prefs.getString('user_data');
        if (p != null) profile = json.decode(p);
        if (u != null) user = json.decode(u);
      } catch (_) {}

      final applicantId = (applicantIdOverride ??
              profile?['applicant_id'] ??
              profile?['id'] ??
              user?['applicant_id'] ??
              user?['user_id'] ??
              user?['id'])
          ?.toString();

      if (applicantId == null || applicantId.isEmpty) {
        return {'success': false, 'message': 'Applicant ID not found. Please log in again.'};
      }

      final base = ApiService.baseUrl;
      final endpoints = <Uri>[
        Uri.parse('$base/api/upload'),
      ];

      Map<String, dynamic> lastError = {'success': false, 'message': 'Upload failed'};
      for (final uri in endpoints) {
        final req = http.MultipartRequest('POST', uri);
        if (token != null && token.isNotEmpty) {
          req.headers['Authorization'] = 'Bearer $token';
        }
        req.headers['Accept'] = 'application/json';

        req.fields['applicant_id'] = applicantId;
        req.files.add(await http.MultipartFile.fromPath(
          'cv',
          filePath,
          contentType: MediaType('application', 'pdf'),
        ));

        try {
          final streamed = await req.send().timeout(const Duration(seconds: 25));
          final resp = await http.Response.fromStream(streamed);
          final raw = resp.body;
          final ctype = resp.headers['content-type'] ?? '';
          Map<String, dynamic> body = {};
          if (raw.isNotEmpty && (ctype.contains('application/json') || raw.trim().startsWith('{') || raw.trim().startsWith('['))) {
            try {
              final decoded = json.decode(raw);
              if (decoded is Map<String, dynamic>) body = decoded;
            } catch (_) {
              // leave body as {}
            }
          }
          // Minimal debug
          // ignore: avoid_print
          print('[UploadService] POST $uri -> ${resp.statusCode} (${ctype.split(";").first})');

          if (resp.statusCode == 200 || resp.statusCode == 201) {
            final uploadResult = {
              'success': true,
              'message': body['message'] ?? 'Upload successful',
              'cvUrl': body['cvUrl'],
              'status': resp.statusCode,
            };

            // Trigger job matching automatically after successful CV upload
            print('[UploadService] CV uploaded successfully, triggering job matching...');
            try {
              final matchResult = await ApiService.triggerJobMatching();
              if (matchResult['success'] == true) {
                print('[UploadService] Job matching triggered successfully: ${matchResult['message']}');
                uploadResult['matchingTriggered'] = true;
                uploadResult['matchedCount'] = matchResult['matchedCount'];
                uploadResult['matchingMessage'] = matchResult['message'];
              } else {
                print('[UploadService] Job matching failed: ${matchResult['message']}');
                uploadResult['matchingTriggered'] = false;
                uploadResult['matchingError'] = matchResult['message'];
              }
            } catch (e) {
              print('[UploadService] Error triggering job matching: $e');
              uploadResult['matchingTriggered'] = false;
              uploadResult['matchingError'] = 'Failed to trigger job matching: $e';
            }

            return uploadResult;
          } else {
            lastError = {
              'success': false,
              'message': (body['error'] ?? body['message'] ?? (raw.isNotEmpty ? raw.substring(0, raw.length.clamp(0, 200)) : 'Upload failed')).toString(),
              'status': resp.statusCode,
            };
          }
        } on SocketException {
          return {'success': false, 'message': 'No internet connection'};
        } on TimeoutException {
          lastError = {'success': false, 'message': 'Upload timed out'};
        } catch (e) {
          lastError = {'success': false, 'message': 'Network error: $e'};
        }
      }
      return lastError;
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getApplicantInfo({String? applicantIdOverride}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Map<String, dynamic>? profile;
      Map<String, dynamic>? user;
      try {
        final p = prefs.getString('profile_data');
        final u = prefs.getString('user_data');
        if (p != null) profile = json.decode(p);
        if (u != null) user = json.decode(u);
      } catch (_) {}

      final applicantId = (applicantIdOverride ??
              profile?['applicant_id'] ??
              profile?['id'] ??
              user?['applicant_id'] ??
              user?['user_id'] ??
              user?['id'])
          ?.toString();

      if (applicantId == null || applicantId.isEmpty) {
        return {'success': false, 'message': 'Applicant ID not found'};
      }

      final headers = <String, String>{
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final base = ApiService.baseUrl;
      final uris = <Uri>[
        Uri.parse('$base/api/applicants/$applicantId'),
      ];

      Map<String, dynamic> lastError = {'success': false, 'message': 'Failed to fetch applicant'};
      for (final uri in uris) {
        try {
          final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));
          // minimal debug
          // ignore: avoid_print
          print('[UploadService] GET $uri -> ${resp.statusCode}');

          if (resp.statusCode == 200) {
            final raw = resp.body.trim();
            dynamic decoded;
            try {
              decoded = raw.isNotEmpty ? json.decode(raw) : {};
            } catch (_) {
              decoded = {};
            }

            Map<String, dynamic> applicant = {};
            if (decoded is List && decoded.isNotEmpty) {
              final first = decoded.first;
              if (first is Map) {
                applicant = first.map((k, v) => MapEntry(k.toString(), v));
              }
            } else if (decoded is Map<String, dynamic>) {
              applicant = decoded;
            }

            return {'success': true, 'applicant': applicant, 'raw': decoded};
          }

          if (resp.statusCode == 404) {
            lastError = {'success': false, 'message': 'Applicant not found', 'status': 404};
            continue;
          }

          Map<String, dynamic> err = {};
          try {
            err = resp.body.isNotEmpty ? json.decode(resp.body) : {};
          } catch (_) {}
          lastError = {
            'success': false,
            'message': (err['error'] ?? err['message'] ?? 'Failed to fetch applicant').toString(),
            'status': resp.statusCode,
          };
        } on SocketException {
          return {'success': false, 'message': 'No internet connection'};
        } on TimeoutException {
          lastError = {'success': false, 'message': 'Request timed out'};
        } catch (e) {
          lastError = {'success': false, 'message': 'Network error: $e'};
        }
      }
      return lastError;
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateApplicantInfo({
    String? applicantIdOverride,
    String? fullName,
    String? universityName,
    String? major,
    String? phoneNumber,
    String? studentEmail,
    String? cvUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Map<String, dynamic>? profile;
      Map<String, dynamic>? user;
      try {
        final p = prefs.getString('profile_data');
        final u = prefs.getString('user_data');
        if (p != null) profile = json.decode(p);
        if (u != null) user = json.decode(u);
      } catch (_) {}

      final applicantId = (applicantIdOverride ??
              profile?['applicant_id'] ??
              profile?['id'] ??
              user?['applicant_id'] ??
              user?['user_id'] ??
              user?['id'])
          ?.toString();

      if (applicantId == null || applicantId.isEmpty) {
        return {'success': false, 'message': 'Applicant ID not found'};
      }

      final payload = <String, dynamic>{};
      if (fullName != null) payload['full_name'] = fullName;
      if (universityName != null) payload['university_name'] = universityName;
      if (major != null) payload['major'] = major;
      if (phoneNumber != null) payload['phone_number'] = phoneNumber;
      if (studentEmail != null) payload['student_email'] = studentEmail;
      if (cvUrl != null) payload['cv_url'] = cvUrl;

      if (payload.isEmpty) {
        return {'success': false, 'message': 'No fields provided to update'};
      }

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final base = ApiService.baseUrl;
      final uri = Uri.parse('$base/api/update/$applicantId');

      final resp = await http
          .post(uri, headers: headers, body: json.encode(payload))
          .timeout(const Duration(seconds: 12));

      // ignore: avoid_print
      print('[UploadService] POST $uri -> ${resp.statusCode}');

      final raw = resp.body.trim();
      Map<String, dynamic> body = {};
      try {
        if (raw.isNotEmpty) {
          final decoded = json.decode(raw);
          if (decoded is Map<String, dynamic>) body = decoded;
        }
      } catch (_) {}

      if (resp.statusCode == 200) {
        final updated = (body['applicant'] is Map<String, dynamic>)
            ? body['applicant'] as Map<String, dynamic>
            : <String, dynamic>{};
        return {'success': true, 'applicant': updated, 'message': body['message'] ?? 'Updated'};
      }

      if (resp.statusCode == 404) {
        return {'success': false, 'message': 'Applicant not found', 'status': 404};
      }

      if (resp.statusCode == 409) {
        return {
          'success': false,
          'message': (body['error'] ?? 'Conflict (e.g., email already in use)').toString(),
          'status': 409
        };
      }

      return {
        'success': false,
        'message': (body['error'] ?? body['message'] ?? 'Failed to update applicant').toString(),
        'status': resp.statusCode
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
}