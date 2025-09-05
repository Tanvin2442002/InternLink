import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApplicationFormPage extends StatefulWidget {
  final String jobId;
  final String applicantId;
  final String internshipTitle;
  final String companyName;
  final String cvUrl; // Pre-filled from profile

  const ApplicationFormPage({
    super.key,
    required this.jobId,
    required this.applicantId,
    required this.internshipTitle,
    required this.companyName,
    required this.cvUrl,
  });

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _fieldController = TextEditingController();
  final _universityController = TextEditingController();
  final _gradYearController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _fieldController.dispose();
    _universityController.dispose();
    _gradYearController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      "job_id": widget.jobId,
      "applicant_id": widget.applicantId,
      "full_name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "date_of_birth": _dobController.text.trim(),
      "address": _addressController.text.trim(),
      "highest_qualification": _qualificationController.text.trim(),
      "field_of_study": _fieldController.text.trim(),
      "university_name": _universityController.text.trim(),
      "graduation_year": _gradYearController.text.trim(),
      "cv_file_url": widget.cvUrl,
    };

    try {
      final result = await ApiService.submitApplication(payload);
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Application Submitted!', style: TextStyle(color: Colors.green)),
            content: Text(result['message'] ?? 'Your application was submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ).then((_) => Navigator.of(context).pop());
      } else {
        _showError(result['error'] ?? result['message'] ?? 'Submission failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Network error: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Internship'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.internshipTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    const SizedBox(height: 4),
                    Text(widget.companyName, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Required fields
            _buildField(_nameController, 'Full Name *', Icons.person, labelStyle, validator: _required),
            _buildField(_emailController, 'Email *', Icons.email, labelStyle, validator: _email),
            _buildField(_phoneController, 'Phone', Icons.phone, labelStyle, keyboardType: TextInputType.phone),
            _buildField(_dobController, 'Date of Birth', Icons.cake, labelStyle, keyboardType: TextInputType.datetime),
            _buildField(_addressController, 'Address', Icons.home, labelStyle),
            _buildField(_qualificationController, 'Highest Qualification', Icons.school, labelStyle),
            _buildField(_fieldController, 'Field of Study', Icons.menu_book, labelStyle),
            _buildField(_universityController, 'University Name', Icons.location_city, labelStyle),
            _buildField(_gradYearController, 'Graduation Year', Icons.calendar_today, labelStyle, keyboardType: TextInputType.number),

            const SizedBox(height: 18),
            Card(
              color: Colors.deepPurple.withOpacity(.07),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
                title: Text('Resume/CV', style: labelStyle),
                subtitle: Text(widget.cvUrl.isNotEmpty ? 'CV attached' : 'No CV found', style: TextStyle(color: Colors.grey[700])),
                trailing: widget.cvUrl.isNotEmpty
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.warning, color: Colors.red),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Submitting...' : 'Submit Application'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: _isLoading ? null : _submitApplication,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    TextStyle labelStyle, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final email = v.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) return 'Invalid email';
    return null;
  }
}