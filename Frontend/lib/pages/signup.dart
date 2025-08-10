import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';

class Boarding2Page extends StatefulWidget {
  const Boarding2Page({super.key});

  @override
  State<Boarding2Page> createState() => _Boarding2PageState();
}

class _Boarding2PageState extends State<Boarding2Page> {
  String _selectedUserType = 'Applicant'; // Default selection
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Password visibility states
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Additional controllers for recruiter fields
  final _companyNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _companyWebsiteController = TextEditingController();

  // Additional controllers for student fields
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  final _phoneController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _positionController.dispose();
    _companyWebsiteController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    // Basic validation
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters long', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Test connection first
      print('🔍 Testing server connection...');
      final connectionTest = await ApiService.testConnection();
      if (!connectionTest) {
        _showSnackBar('Unable to connect to server. Please check your internet connection.', isError: true);
        return;
      }
      print('✅ Server connection successful');

      // Prepare profile data based on user type
      Map<String, dynamic> profileData;
      
      if (_selectedUserType == 'Applicant') {
        profileData = {
          'fullName': _nameController.text.trim(),
          'universityName': _universityController.text.trim(),
          'major': _majorController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'studentEmail': _emailController.text.trim(),
        };
      } else {
        profileData = {
          'fullName': _nameController.text.trim(),
          'companyName': _companyNameController.text.trim(),
          'positionTitle': _positionController.text.trim(),
          'companyWebsite': _companyWebsiteController.text.trim(),
          'workEmail': _emailController.text.trim(),
        };
      }

      final result = await ApiService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _selectedUserType,
        profileData: profileData,
      );

      if (result['success']) {
        _showSnackBar('Account created successfully!');
        // Navigate to login page
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred. Please try again.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurple : Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
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
                          'Create Your Account',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Page Indicators - signup is active (4th dot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(isActive: false),  // boarding0
                      const SizedBox(width: 8),
                      _buildDot(isActive: false),  // boarding1
                      const SizedBox(width: 8),
                      _buildDot(isActive: false),  // boarding3
                      const SizedBox(width: 8),
                      _buildDot(isActive: true),   // signup - ACTIVE
                    ],
                  ),

                  const SizedBox(height: 16),

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
                                  padding: const EdgeInsets.all(12),
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
                                        size: 28,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Student/\nApplicant',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedUserType == 'Applicant'
                                              ? Colors.white
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
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
                                  padding: const EdgeInsets.all(12),
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
                                        size: 28,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Company/\nRecruiter',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedUserType == 'Recruiter'
                                              ? Colors.white
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
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

                  const SizedBox(height: 24),

                  // Tabs (Login / Signup)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 32),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(thickness: 2),
                  const SizedBox(height: 16),

                  // Full Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full name',
                      prefixIcon: const Icon(Icons.person_outlined),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Student-specific fields
                  if (_selectedUserType == 'Applicant') ...[
                    // University/College
                    TextField(
                      controller: _universityController,
                      decoration: InputDecoration(
                        hintText: 'University/College name',
                        prefixIcon: const Icon(Icons.school_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Major/Field of Study
                    TextField(
                      controller: _majorController,
                      decoration: InputDecoration(
                        hintText: 'Major/Field of study',
                        prefixIcon: const Icon(Icons.auto_stories_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Recruiter-specific fields
                  if (_selectedUserType == 'Recruiter') ...[
                    TextField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        hintText: 'Company name',
                        prefixIcon: const Icon(Icons.business_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Position/Title (only for recruiters)
                    TextField(
                      controller: _positionController,
                      decoration: InputDecoration(
                        hintText: 'Your position/title',
                        prefixIcon: const Icon(Icons.work_outline),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Company Website (optional for recruiters)
                    TextField(
                      controller: _companyWebsiteController,
                      decoration: InputDecoration(
                        hintText: 'Company website (optional)',
                        prefixIcon: const Icon(Icons.language_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: _selectedUserType == 'Recruiter' ? 'Work email address' : 'Student email address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Password - WITH WORKING VISIBILITY TOGGLE
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password - WITH WORKING VISIBILITY TOGGLE
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Student info notice
                  if (_selectedUserType == 'Applicant') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your academic information helps us match you with relevant internships.',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Terms and conditions (for recruiters)
                  if (_selectedUserType == 'Recruiter') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Company accounts require verification before posting jobs.',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Gradient Sign Up Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A5AE0), Color(0xFF8F41F4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp, // Disable when loading
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sign Up as $_selectedUserType',
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                  const SizedBox(height: 12),

                  // Social Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.google, size: 18),
                          label: const Text('Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.linkedin, size: 18),
                          label: const Text('LinkedIn'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Expanded(child: SizedBox()),

                  // Bottom Sign in
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Sign in'),
                        ),
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
