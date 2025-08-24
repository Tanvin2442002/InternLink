import 'package:flutter/material.dart';
import '../pages/reset_password_page.dart';

class DeepLinkHandler {
  static void handleResetPasswordLink(BuildContext context, String url) {
    final uri = Uri.parse(url);
    final token = uri.queryParameters['token'];
    
    if (token != null && token.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(token: token),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid reset link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  static bool isResetPasswordLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.path.contains('reset-password') && 
             uri.queryParameters.containsKey('token');
    } catch (e) {
      return false;
    }
  }
}