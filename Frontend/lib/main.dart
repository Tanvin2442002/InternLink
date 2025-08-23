import 'package:flutter/material.dart';
import 'package:interlink/pages/boarding0.dart';
import 'package:interlink/pages/boarding1.dart';
import 'package:interlink/pages/signup.dart';
import 'package:interlink/pages/boarding3.dart';
import 'package:interlink/pages/login_page.dart';
import 'package:interlink/pages/main_nav_page.dart';
import 'package:interlink/pages/recruiter_main_nav_page.dart';
import 'package:interlink/pages/forgot_password_page.dart';
import 'package:interlink/pages/reset_password_page.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InternshipApp());
}

class InternshipApp extends StatelessWidget {
  const InternshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internship AI Match',
      debugShowCheckedModeBanner: false,
      home: const AppInitializer(),
      routes: {
        '/boarding0': (context) => const Boarding0Page(),
        '/boarding1': (context) => const Boarding1Page(),
        '/boarding2': (context) => const Boarding2Page(), // This is signup
        '/boarding3': (context) => const Boarding3Page(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainNavigationPage(),
        '/recruiter_main': (context) => const RecruiterMainNavigationPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      
      if (isLoggedIn) {
        final userData = await ApiService.getUserData();
        if (userData != null) {
          final userType = userData['user_type'];
          if (userType == 'recruiter') {
            Navigator.pushReplacementNamed(context, '/recruiter_main');
          } else {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/boarding0');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/boarding0');
      }
    } catch (e) {
      // If there's an error, go to boarding
      Navigator.pushReplacementNamed(context, '/boarding0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

