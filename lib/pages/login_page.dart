import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main_nav_page.dart';
import 'recruiter_main_nav_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedUserType = 'Applicant'; // Default selection
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Navigate based on user type
    if (_selectedUserType == 'Recruiter') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RecruiterMainNavigationPage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Added SingleChildScrollView
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox( // Added ConstrainedBox to ensure minimum height
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight( // Added IntrinsicHeight
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'InternLink',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find Your Perfect Internship',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32), // Reduced from 40

                  // User Type Selection
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I am a:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedUserType = 'Applicant';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12), // Reduced from 16
                                  decoration: BoxDecoration(
                                    color: _selectedUserType == 'Applicant'
                                        ? Colors.deepPurple
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedUserType == 'Applicant'
                                          ? Colors.deepPurple
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: _selectedUserType == 'Applicant'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        size: 28, // Reduced from 32
                                      ),
                                      const SizedBox(height: 6), // Reduced from 8
                                      Text(
                                        'Student/\nApplicant',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedUserType == 'Applicant'
                                              ? Colors.white
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13, // Reduced from 14
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedUserType = 'Recruiter';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12), // Reduced from 16
                                  decoration: BoxDecoration(
                                    color: _selectedUserType == 'Recruiter'
                                        ? Colors.deepPurple
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedUserType == 'Recruiter'
                                          ? Colors.deepPurple
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.business,
                                        color: _selectedUserType == 'Recruiter'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        size: 28, // Reduced from 32
                                      ),
                                      const SizedBox(height: 6), // Reduced from 8
                                      Text(
                                        'Company/\nRecruiter',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedUserType == 'Recruiter'
                                              ? Colors.white
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13, // Reduced from 14
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24), // Reduced from 32

                  // Tabs (Login / Signup)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const Divider(thickness: 2),
                  const SizedBox(height: 16), // Reduced from 20

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric( // Added to reduce height
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: const Icon(Icons.visibility_outlined),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric( // Added to reduce height
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced from 8

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 12), // Reduced from 16

                  // Gradient Login Button
                  Container(
                    width: double.infinity,
                    height: 48, // Reduced from 50
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A5AE0), Color(0xFF8F41F4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login as $_selectedUserType',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16), // Reduced from 20

                  // Or continue with
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('Or continue with'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12), // Reduced from 16

                  // Social Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.google, size: 18), // Reduced icon size
                          label: const Text('Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40), // Reduced height
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.linkedin, size: 18), // Reduced icon size
                          label: const Text('LinkedIn'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40), // Reduced height
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Expanded(child: SizedBox()), // Changed Spacer to Expanded SizedBox

                  // Bottom Sign up
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16), // Added bottom padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(onPressed: () {}, child: const Text('Sign up')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
