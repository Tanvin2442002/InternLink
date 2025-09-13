import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../services/uploadservice.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onCvUploaded;

  const ProfilePage({super.key, required this.onCvUploaded});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Applicant data
  bool isLoading = true;
  String? loadError;
  Map<String, dynamic>? applicant;

  // Upload state
  bool isCvUploaded = false;
  String? selectedFileName;
  String? selectedFilePath;
  bool isUploading = false;
  String? lastUploadedUrl;

  @override
  void initState() {
    super.initState();
    _fetchApplicant();
  }

  Future<void> _fetchApplicant() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    final res = await UploadService.getApplicantInfo();
    if (!mounted) return;

    if (res['success'] == true) {
      final data = (res['applicant'] is Map<String, dynamic>) ? res['applicant'] as Map<String, dynamic> : <String, dynamic>{};
      final cvUrl = (data['cv_url'] ?? '').toString();
      setState(() {
        applicant = data;
        lastUploadedUrl = cvUrl.isNotEmpty ? cvUrl : null;
        isCvUploaded = cvUrl.isNotEmpty;
        isLoading = false;
      });
    } else {
      setState(() {
        loadError = res['message']?.toString() ?? 'Failed to load profile';
        isLoading = false;
      });
    }
  }

  Future<void> _previewRemote(String url) async {
    if (url.isEmpty) return;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open CV URL')));
    }
  }

  Future<void> _previewLocal(String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preview failed: ${result.message ?? 'Unknown error'}')),
        );
      }
    } on MissingPluginException {
      // Fallback to system handler
      final ok = await launchUrl(Uri.file(path), mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preview unavailable. Do a full rebuild: flutter clean, then flutter run.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preview error: $e')));
    }
  }

  Future<bool?> _confirmUploadDialog({
    required String name,
    required int sizeBytes,
    required String path,
  }) {
    final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload CV?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: $name'),
            const SizedBox(height: 6),
            Text('Size: $sizeMB MB'),
            const SizedBox(height: 12),
            const Text('Make sure this is the correct PDF.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _previewLocal(path),
            child: const Text('Preview'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> uploadCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    if (result == null) return; // canceled

    final file = result.files.single;
    if (file.path == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to read file path')));
      return;
    }
    
    // Check file size - max 3MB
    const maxSizeBytes = 3 * 1024 * 1024; // 3MB in bytes
    if (file.size > maxSizeBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File too large (max 3MB)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirm before uploading
    final confirm = await _confirmUploadDialog(name: file.name, sizeBytes: file.size, path: file.path!);
    if (confirm != true) return;

    setState(() {
      selectedFileName = file.name;
      selectedFilePath = file.path!;
      isUploading = true;
    });

    // First validate if the file is actually a CV using Gemini
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Validating CV content with AI...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    final validationRes = await UploadService.validateCvContent(filePath: selectedFilePath!);
    
    if (!mounted) return;
    
    if (validationRes['success'] != true) {
      setState(() {
        isUploading = false;
      });
      
      final message = validationRes['message']?.toString() ?? 'CV validation failed';
      final details = validationRes['details'];
      
      // Show detailed error dialog for validation failures
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CV Validation Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (details != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reason: ${details['reasoning'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Please upload a valid CV/Resume that includes:\n'
                '• Personal information\n'
                '• Education history\n'
                '• Work experience\n'
                '• Skills section',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // If validation passed, proceed with upload
    if (!mounted) return;
    final validationDetails = validationRes['details'];
    final confidence = validationDetails?['confidence'] ?? 'unknown';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CV validated successfully (confidence: $confidence). Uploading...'),
        backgroundColor: Colors.green,
      ),
    );

    final res = await UploadService.uploadCvFile(filePath: selectedFilePath!);

    if (!mounted) return;
    setState(() {
      isUploading = false;
      isCvUploaded = res['success'] == true;
      lastUploadedUrl = res['cvUrl']?.toString() ?? lastUploadedUrl;
    });

    // Create upload success message
    String message = res['message']?.toString() ?? (res['success'] == true ? 'Upload successful' : 'Upload failed');
    
    // Add job matching information if available
    if (res['success'] == true && res['matchingTriggered'] == true) {
      final matchedCount = res['matchedCount']?.toString() ?? '0';
      message += '\n🎯 Found $matchedCount matching jobs for you!';
    } else if (res['success'] == true && res['matchingTriggered'] == false) {
      message += '\n⚠️ Job matching will be updated shortly';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4), // Longer duration for more info
      ),
    );

    if (res['success'] == true) {
      widget.onCvUploaded();
      // Refresh to reflect new cv_url if backend saved it
      _fetchApplicant();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvUrl = lastUploadedUrl ?? (applicant?['cv_url']?.toString() ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _fetchApplicant,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: isLoading || applicant == null ? null : _openEditProfile,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 36),
                        const SizedBox(height: 8),
                        Text(loadError!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _fetchApplicant, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header card (responsive, no overflow)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.indigo.shade500, Colors.indigo.shade300]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 36, color: Colors.indigo),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (applicant?['full_name'] ?? 'Applicant').toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (applicant?['student_email'] ?? '').toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white.withOpacity(.95)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isCvUploaded ? Colors.greenAccent.shade100 : Colors.orangeAccent.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(isCvUploaded ? Icons.check_circle : Icons.info, size: 16, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Text(
                                    isCvUploaded ? 'CV on file' : 'CV missing',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Details card (no IDs displayed)
                      _buildSectionCard(
                        title: 'About',
                        child: Column(
                          children: [
                            _buildInfoTile('University', (applicant?['university_name'] ?? '—').toString(), leading: Icons.school),
                            _buildInfoTile('Major', (applicant?['major'] ?? '—').toString(), leading: Icons.menu_book),
                            _buildInfoTile('Phone', (applicant?['phone_number'] ?? '—').toString(), leading: Icons.phone),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CV card
                      _buildSectionCard(
                        title: 'Curriculum Vitae',
                        icon: Icons.description_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedFileName != null)
                              Text(
                                selectedFileName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              )
                            else
                              const Text('Upload your CV (PDF)', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('Supported: PDF (Max 5MB)', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 10),
                            // Wrap avoids overflow on small screens
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: isUploading ? null : uploadCV,
                                  icon: Icon(isUploading ? Icons.hourglass_top : Icons.upload_file),
                                  label: Text(isUploading ? 'Uploading...' : 'Choose PDF and Upload'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: (cvUrl.isNotEmpty && !isUploading) ? () => _previewRemote(cvUrl) : null,
                                  icon: const Icon(Icons.visibility_outlined),
                                  label: const Text('Preview current CV'),
                                ),
                                if (selectedFilePath != null && !isUploading)
                                  OutlinedButton.icon(
                                    onPressed: () => _previewLocal(selectedFilePath!),
                                    icon: const Icon(Icons.remove_red_eye_outlined),
                                    label: const Text('Preview selected'),
                                  ),
                              ],
                            ),
                            // Do not show raw cv_url string per request
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _fetchApplicant,
                          icon: const Icon(Icons.sync),
                          label: const Text('Refresh Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Helper to build a consistent card for each section
  Widget _buildSectionCard({required String title, IconData? icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.indigo),
                const SizedBox(width: 8),
              ],
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, {IconData? leading}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: leading != null ? Icon(leading, color: Colors.indigo) : null,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final data = applicant ?? <String, dynamic>{};
    final nameCtrl = TextEditingController(text: (data['full_name'] ?? '').toString());
    final uniCtrl = TextEditingController(text: (data['university_name'] ?? '').toString());
    final majorCtrl = TextEditingController(text: (data['major'] ?? '').toString());
    final phoneCtrl = TextEditingController(text: (data['phone_number'] ?? '').toString());
    final emailCtrl = TextEditingController(text: (data['student_email'] ?? '').toString());

    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> submit() async {
              if (saving) return;
              // Compute only changed fields
              final current = applicant ?? {};
              String trimOrEmpty(String s) => s.trim();
              final nextFullName = trimOrEmpty(nameCtrl.text);
              final nextUni = trimOrEmpty(uniCtrl.text);
              final nextMajor = trimOrEmpty(majorCtrl.text);
              final nextPhone = trimOrEmpty(phoneCtrl.text);
              final nextEmail = trimOrEmpty(emailCtrl.text);

              String getStr(dynamic v) => v?.toString() ?? '';
              final origFullName = getStr(current['full_name']);
              final origUni = getStr(current['university_name']);
              final origMajor = getStr(current['major']);
              final origPhone = getStr(current['phone_number']);
              final origEmail = getStr(current['student_email']);

              final fullName = nextFullName != origFullName ? nextFullName : null;
              final universityName = nextUni != origUni ? nextUni : null;
              final major = nextMajor != origMajor ? nextMajor : null;
              final phoneNumber = nextPhone != origPhone ? nextPhone : null;
              final studentEmail = nextEmail != origEmail ? nextEmail : null;

              if (fullName == null &&
                  universityName == null &&
                  major == null &&
                  phoneNumber == null &&
                  studentEmail == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No changes to update')),
                  );
                }
                return;
              }

              setModalState(() => saving = true);
              final res = await UploadService.updateApplicantInfo(
                fullName: fullName,
                universityName: universityName,
                major: major,
                phoneNumber: phoneNumber,
                studentEmail: studentEmail,
              );
              setModalState(() => saving = false);

              if (!mounted) return;
              if (res['success'] == true) {
                // Prefer server-returned applicant; otherwise merge locally
                final updated = (res['applicant'] is Map<String, dynamic>)
                    ? res['applicant'] as Map<String, dynamic>
                    : {
                        ...?applicant,
                        if (fullName != null) 'full_name': fullName,
                        if (universityName != null) 'university_name': universityName,
                        if (major != null) 'major': major,
                        if (phoneNumber != null) 'phone_number': phoneNumber,
                        if (studentEmail != null) 'student_email': studentEmail,
                      };
                setState(() => applicant = updated);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message']?.toString() ?? 'Profile updated'), backgroundColor: Colors.green),
                );
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message']?.toString() ?? 'Update failed'), backgroundColor: Colors.red),
                );
              }
            }

            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.indigo),
                          const SizedBox(width: 8),
                          const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: uniCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'University', prefixIcon: Icon(Icons.school)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: majorCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Major', prefixIcon: Icon(Icons.menu_book)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneCtrl,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailCtrl,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Student Email', prefixIcon: Icon(Icons.email)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saving ? null : submit,
                          icon: Icon(saving ? Icons.hourglass_top : Icons.save),
                          label: Text(saving ? 'Saving...' : 'Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
