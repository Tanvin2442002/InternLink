import 'package:flutter/material.dart';
import 'package:interlink/pages/boarding0.dart';
import 'package:interlink/pages/boarding1.dart';
import 'package:interlink/pages/signup.dart';
import 'package:interlink/pages/boarding3.dart';
import 'package:interlink/pages/login_page.dart';

void main() {
  runApp(const InternshipApp());
}

class InternshipApp extends StatelessWidget {
  const InternshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internship AI Match',
      debugShowCheckedModeBanner: false,
      initialRoute: '/boarding0',
      routes: {
        '/boarding0': (context) => const Boarding0Page(),
        '/boarding1': (context) => const Boarding1Page(),
        '/boarding2': (context) => const Boarding2Page(), // This is actually the signup page
        '/boarding3': (context) => const Boarding3Page(),
        '/login': (context) => const LoginPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
    );
  }
}

