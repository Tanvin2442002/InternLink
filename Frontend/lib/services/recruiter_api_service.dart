import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecruiterApiService {
  static const String baseUrl = 'http://192.168.68.109:5000'; // Match existing API service

  // Helper method to get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Helper method to get current user ID from storage
  static Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        return userData['user_id'];
      }
    } catch (e) {
      print('🔍 [RECRUITER API] Error getting user ID: $e');
    }
    return null;
  }

  // PROFILE MANAGEMENT
  
  /// Get recruiter profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('🔍 [RECRUITER API] Getting profile for user: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/recruiter/profile/$userId'),
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Profile response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['recruiter'];
        } else {
          throw Exception(data['error'] ?? 'Failed to get profile');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error getting profile: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update recruiter profile
  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String companyName,
    String? positionTitle,
    String? companyWebsite,
    String? workEmail,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('🔄 [RECRUITER API] Updating profile for user: $userId');

      final requestBody = {
        'full_name': fullName,
        'company_name': companyName,
        if (positionTitle != null) 'position_title': positionTitle,
        if (companyWebsite != null) 'company_website': companyWebsite,
        if (workEmail != null) 'work_email': workEmail,
      };

      print('📝 [RECRUITER API] Update data: $requestBody');

      final response = await http.put(
        Uri.parse('$baseUrl/api/recruiter/profile/$userId'),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      print('📋 [RECRUITER API] Update response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['recruiter'];
        } else {
          throw Exception(data['error'] ?? 'Failed to update profile');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // JOB MANAGEMENT

  /// Get all jobs for recruiter
  static Future<Map<String, dynamic>> getJobs({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('🔍 [RECRUITER API] Getting jobs for recruiter: $userId');
      print('📄 [RECRUITER API] Query params: page=$page, limit=$limit, status=$status');

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('$baseUrl/api/recruiter/jobs/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Jobs response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Jobs response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'jobs': data['jobs'],
            'pagination': data['pagination'],
          };
        } else {
          throw Exception(data['error'] ?? 'Failed to get jobs');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error getting jobs: $e');
      throw Exception('Failed to get jobs: $e');
    }
  }

  /// Create a new job
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String companyName,
    String? companyLogoUrl,
    String? companyDescription,
    String? roleType,
    String? employmentType,
    int? durationMonths,
    String? stipend,
    String? location,
    String? closingDate,
    String? roleOverview,
    String? requiredSkills,
    String? perks,
    String? eligibility,
    String? tags,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('➕ [RECRUITER API] Creating job: $title');

      final requestBody = {
        'recruiter_id': userId,
        'title': title,
        'company_name': companyName,
        if (companyLogoUrl != null) 'company_logo_url': companyLogoUrl,
        if (companyDescription != null) 'company_description': companyDescription,
        if (roleType != null) 'role_type': roleType,
        if (employmentType != null) 'employment_type': employmentType,
        if (durationMonths != null) 'duration_months': durationMonths,
        if (stipend != null) 'stipend': stipend,
        if (location != null) 'location': location,
        if (closingDate != null) 'closing_date': closingDate,
        if (roleOverview != null) 'role_overview': roleOverview,
        if (requiredSkills != null) 'required_skills': requiredSkills,
        if (perks != null) 'perks': perks,
        if (eligibility != null) 'eligibility': eligibility,
        if (tags != null) 'tags': tags,
      };

      print('📝 [RECRUITER API] Job data: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/api/recruiter/jobs'),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      print('📋 [RECRUITER API] Create job response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Create job response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['job'];
        } else {
          throw Exception(data['error'] ?? 'Failed to create job');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error creating job: $e');
      throw Exception('Failed to create job: $e');
    }
  }

  /// Update a job
  static Future<Map<String, dynamic>> updateJob({
    required String jobId,
    String? title,
    String? roleType,
    String? employmentType,
    int? durationMonths,
    String? stipend,
    String? location,
    String? closingDate,
    String? roleOverview,
    String? requiredSkills,
    String? perks,
    String? eligibility,
    String? tags,
    String? status,
  }) async {
    try {
      print('🔄 [RECRUITER API] Updating job: $jobId');

      final requestBody = <String, dynamic>{};
      if (title != null) requestBody['title'] = title;
      if (roleType != null) requestBody['role_type'] = roleType;
      if (employmentType != null) requestBody['employment_type'] = employmentType;
      if (durationMonths != null) requestBody['duration_months'] = durationMonths;
      if (stipend != null) requestBody['stipend'] = stipend;
      if (location != null) requestBody['location'] = location;
      if (closingDate != null) requestBody['closing_date'] = closingDate;
      if (roleOverview != null) requestBody['role_overview'] = roleOverview;
      if (requiredSkills != null) requestBody['required_skills'] = requiredSkills;
      if (perks != null) requestBody['perks'] = perks;
      if (eligibility != null) requestBody['eligibility'] = eligibility;
      if (tags != null) requestBody['tags'] = tags;
      if (status != null) requestBody['status'] = status;

      print('📝 [RECRUITER API] Update data: $requestBody');

      final response = await http.put(
        Uri.parse('$baseUrl/api/recruiter/jobs/$jobId'),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      print('📋 [RECRUITER API] Update job response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Update job response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['job'];
        } else {
          throw Exception(data['error'] ?? 'Failed to update job');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error updating job: $e');
      throw Exception('Failed to update job: $e');
    }
  }

  /// Delete a job
  static Future<void> deleteJob(String jobId) async {
    try {
      print('🗑️ [RECRUITER API] Deleting job: $jobId');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/recruiter/jobs/$jobId'),
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Delete job response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Delete job response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['error'] ?? 'Failed to delete job');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error deleting job: $e');
      throw Exception('Failed to delete job: $e');
    }
  }

  // APPLICATION MANAGEMENT

  /// Get applications for recruiter's jobs
  static Future<Map<String, dynamic>> getApplications({
    int page = 1,
    int limit = 10,
    String? status,
    String? jobId,
    String? search,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('🔍 [RECRUITER API] Getting applications for user: $userId');
      print('📄 [RECRUITER API] Query params: page=$page, limit=$limit, status=$status, jobId=$jobId, search=$search');

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (jobId != null) 'job_id': jobId,
        if (search != null) 'search': search,
      };

      final uri = Uri.parse('$baseUrl/api/recruiter/applications/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Applications response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Applications response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'applications': data['applications'],
            'pagination': data['pagination'],
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to get applications',
          };
        }
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error getting applications: $e');
      return {
        'success': false,
        'message': 'Failed to get applications: $e',
      };
    }
  }

  /// Update application status
  static Future<Map<String, dynamic>> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? recruiterNotes,
  }) async {
    try {
      print('🔄 [RECRUITER API] Updating application status: $applicationId -> $status');

      final requestBody = {
        'status': status,
        if (recruiterNotes != null) 'recruiter_notes': recruiterNotes,
      };

      print('📝 [RECRUITER API] Status update data: $requestBody');

      final response = await http.put(
        Uri.parse('$baseUrl/api/recruiter/applications/$applicationId/status'),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      print('📋 [RECRUITER API] Update status response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Update status response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'application': data['application'],
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to update application status',
          };
        }
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error updating application status: $e');
      return {
        'success': false,
        'message': 'Failed to update application status: $e',
      };
    }
  }

  // ANALYTICS

  /// Get analytics dashboard
  static Future<Map<String, dynamic>> getAnalytics({
    String period = 'month',
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('📊 [RECRUITER API] Getting analytics for recruiter: $userId');
      print('📅 [RECRUITER API] Period: $period');

      final queryParams = {'period': period};
      final uri = Uri.parse('$baseUrl/api/recruiter/analytics/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Analytics response status: ${response.statusCode}');
      print('📋 [RECRUITER API] Analytics response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['analytics'];
        } else {
          throw Exception(data['error'] ?? 'Failed to get analytics');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error getting analytics: $e');
      throw Exception('Failed to get analytics: $e');
    }
  }

  // EXTENDED FEATURES (from RecruiterExtended.js)

  /// Get notifications
  static Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('🔔 [RECRUITER API] Getting notifications for recruiter: $userId');

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'unread_only': unreadOnly.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/recruiter/notifications/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Notifications response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'notifications': data['notifications'],
            'unread_count': data['unread_count'],
          };
        } else {
          throw Exception(data['error'] ?? 'Failed to get notifications');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error getting notifications: $e');
      throw Exception('Failed to get notifications: $e');
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      print('🔄 [RECRUITER API] Marking notification as read: $notificationId');

      final response = await http.put(
        Uri.parse('$baseUrl/api/recruiter/notifications/$notificationId/read'),
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Mark read response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['error'] ?? 'Failed to mark notification as read');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Schedule an interview
  static Future<Map<String, dynamic>> scheduleInterview({
    required String applicationId,
    required String interviewType,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? location,
    String? notes,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('➕ [RECRUITER API] Scheduling interview for application: $applicationId');

      final requestBody = {
        'application_id': applicationId,
        'recruiter_id': userId,
        'interview_type': interviewType,
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/recruiter/interviews'),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      print('📋 [RECRUITER API] Schedule interview response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['interview'];
        } else {
          throw Exception(data['error'] ?? 'Failed to schedule interview');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error scheduling interview: $e');
      throw Exception('Failed to schedule interview: $e');
    }
  }

  /// Get interviews
  static Future<List<Map<String, dynamic>>> getInterviews({
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('🔍 [RECRUITER API] Getting interviews for recruiter: $userId');

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;

      final uri = Uri.parse('$baseUrl/api/recruiter/interviews/$userId')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Interviews response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['interviews']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get interviews');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error getting interviews: $e');
      throw Exception('Failed to get interviews: $e');
    }
  }

  /// Save an applicant
  static Future<Map<String, dynamic>> saveApplicant({
    required String applicantId,
    String? tags,
    String? notes,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('➕ [RECRUITER API] Saving applicant: $applicantId');

      final requestBody = {
        'recruiter_id': userId,
        'applicant_id': applicantId,
        if (tags != null) 'tags': tags,
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/recruiter/saved-applicants'),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      print('📋 [RECRUITER API] Save applicant response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['saved_applicant'];
        } else {
          throw Exception(data['error'] ?? 'Failed to save applicant');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error saving applicant: $e');
      throw Exception('Failed to save applicant: $e');
    }
  }

  /// Get saved applicants
  static Future<List<Map<String, dynamic>>> getSavedApplicants({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user ID found');
      }

      print('🔍 [RECRUITER API] Getting saved applicants for recruiter: $userId');

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/recruiter/saved-applicants/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('📋 [RECRUITER API] Saved applicants response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['saved_applicants']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get saved applicants');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RECRUITER API] Error getting saved applicants: $e');
      throw Exception('Failed to get saved applicants: $e');
    }
  }

  // UTILITY METHODS

  /// Test connection to recruiter API
  static Future<bool> testConnection() async {
    try {
      print('🔍 [RECRUITER API] Testing connection...');
      
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/recruiter/profile/test'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 5));
      
      final isConnected = response.statusCode == 400 || // Expected for missing ID
          response.statusCode == 200 ||
          response.statusCode == 404;
      
      print(isConnected ? '✅ [RECRUITER API] Connection successful' : '❌ [RECRUITER API] Connection failed');
      return isConnected;
    } catch (e) {
      print('💥 [RECRUITER API] Connection test error: $e');
      return false;
    }
  }

  /// Validate application status
  static bool isValidApplicationStatus(String status) {
    const validStatuses = [
      'applied', 'reviewed', 'shortlisted', 'interviewed', 
      'offered', 'hired', 'rejected'
    ];
    return validStatuses.contains(status.toLowerCase());
  }

  /// Format status for display
  static String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return 'Applied';
      case 'reviewed':
        return 'Reviewed';
      case 'shortlisted':
        return 'Shortlisted';
      case 'interviewed':
        return 'Interviewed';
      case 'offered':
        return 'Offered';
      case 'hired':
        return 'Hired';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
