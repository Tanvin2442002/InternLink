import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class UploadService {
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
            return {
              'success': true,
              'message': body['message'] ?? 'Upload successful',
              'cvUrl': body['cvUrl'],
              'status': resp.statusCode,
            };
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
}