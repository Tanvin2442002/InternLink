import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onCvUploaded;

  const ProfilePage({super.key, required this.onCvUploaded});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isCvUploaded = false;
  String? selectedFileName;

  // void uploadCV() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'doc', 'docx'],
  //   );

  //   if (result != null && result.files.single.size <= 5 * 1024 * 1024) {
  //     setState(() {
  //       selectedFileName = result.files.single.name;
  //       isCvUploaded = true;
  //     });
  //     widget.onCvUploaded();
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Invalid file or size > 5MB")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isCvUploaded)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(child: Text("Please upload your CV to continue", style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 8),
            const Text("Pallab", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text("Edit Profile")),

            const SizedBox(height: 16),
            buildInfoTile("Full Name", "Pallab"),
            buildInfoTile("Email Address", "pallab@gmail.com"),
            buildInfoTile("University", "MIST"),
            buildInfoTile("Major/Course", "Computer Science"),
            buildInfoTile("Expected Graduation", "March 2026"),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 40),
                  const SizedBox(height: 8),
                  Text(selectedFileName ?? "Upload your CV"),
                  const Text("Supported formats: PDF, DOC, DOCX (Max 5MB)"),
                  const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: uploadCV,
                  //   child: const Text("Choose File"),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Text("Skills", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Spacer(),
                Text("Edit", style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text("React")),
                Chip(label: Text("JavaScript")),
                Chip(label: Text("UI/UX Design")),
                Chip(label: Text("TypeScript")),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
