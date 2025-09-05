import 'package:flutter/material.dart';
import 'application_form_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // <-- add this import

class InternshipDetailsPage extends StatelessWidget {
  final Map<String, dynamic> job;
  const InternshipDetailsPage({super.key, required this.job});

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return 'N/A';
    }
  }

  IconData _perkIcon(String key) {
    switch (key.toLowerCase()) {
      case 'clock':
        return Icons.access_time;
      case 'graduation-cap':
        return Icons.school;
      case 'certificate':
        return Icons.verified;
      case 'users':
        return Icons.group;
      case 'trending-up':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = (job['company_name'] ?? 'Unknown Company').toString();
    final title = (job['title'] ?? 'Internship').toString();
    final logoUrl = (job['company_logo_url'] ?? '').toString();

    // chips (prefer tags; else fallback to location/duration/stipend)
    final List<String> tags = (job['tags'] is List)
        ? (job['tags'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final location = (job['location'] ?? job['employment_type'] ?? 'Remote')
        .toString();
    final duration = job['duration_months'] != null
        ? '${(job['duration_months'] is num ? (job['duration_months'] as num).toInt() : int.tryParse(job['duration_months'].toString()) ?? 0)} Months'
        : 'N/A';
    final stipend = (job['stipend'] ?? 'N/A').toString();

    final appliedCount = job['applied_count']?.toString() ?? '0';
    final postedReadable =
        (job['extra_meta'] is Map &&
            job['extra_meta']['posted_readable'] != null)
        ? job['extra_meta']['posted_readable'].toString()
        : null;
    final closingDate = _formatDate(job['closing_date']?.toString());

    final companyDesc = (job['company_description'] ?? '').toString();

    final List<String> roleOverview = (job['role_overview'] is List)
        ? (job['role_overview'] as List).map((e) => e.toString()).toList()
        : const [];

    final List<String> skills = (job['required_skills'] is List)
        ? (job['required_skills'] as List).map((e) => e.toString()).toList()
        : const [];

    final List<String> eligibility = (job['eligibility'] is List)
        ? (job['eligibility'] as List).map((e) => e.toString()).toList()
        : const [];

    final List<Map<String, dynamic>> perks = (job['perks'] is List)
        ? (job['perks'] as List)
              .map(
                (p) => (p is Map)
                    ? p.map((k, v) => MapEntry(k.toString(), v))
                    : <String, dynamic>{},
              )
              .cast<Map<String, dynamic>>()
              .toList()
        : const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Internship Details"),
        leading: const BackButton(),
        actions: const [Icon(Icons.bookmark_border)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: logoUrl.isNotEmpty
                      ? Image.network(
                          logoUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.business,
                            color: Colors.grey,
                            size: 28,
                          ),
                        )
                      : const Icon(
                          Icons.business,
                          color: Colors.grey,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(company, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children:
                (tags.isNotEmpty ? tags : <String>[location, duration, stipend])
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoIcon(
                icon: Icons.person_outline,
                label: '$appliedCount Applied',
              ),
              InfoIcon(
                icon: Icons.access_time,
                label: postedReadable ?? 'Recently',
              ),
              InfoIcon(icon: Icons.calendar_today, label: closingDate),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader("About $company"),
          Text(
            companyDesc.isNotEmpty
                ? companyDesc
                : "Company description not provided.",
          ),
          const SizedBox(height: 16),
          const SectionHeader("Role Overview"),
          BulletList(
            roleOverview.isNotEmpty
                ? roleOverview
                : const ["Details not provided."],
          ),
          const SectionHeader("Required Skills"),
          Wrap(
            spacing: 8,
            children: skills.isEmpty
                ? [
                    Text(
                      'Not specified',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ]
                : skills.map((s) => Chip(label: Text(s))).toList(),
          ),
          const SectionHeader("Eligibility"),
          BulletList(
            eligibility.isNotEmpty ? eligibility : const ["Not specified"],
          ),
          const SectionHeader("Perks & Benefits"),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: perks.isEmpty
                ? const [Text('Not specified')]
                : perks
                      .map(
                        (p) => BenefitItem(
                          icon: _perkIcon((p['icon'] ?? '').toString()),
                          label: (p['name'] ?? '').toString(),
                        ),
                      )
                      .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    // Fetch applicant info from SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    Map<String, dynamic>? profile;
                    try {
                      final p = prefs.getString('profile_data');
                      if (p != null)
                        profile = Map<String, dynamic>.from(jsonDecode(p));
                    } catch (_) {}

                    final applicantId =
                        profile?['applicant_id']?.toString() ?? '';
                    final cvUrl = profile?['cv_url']?.toString() ?? '';

                    if (applicantId.isEmpty || cvUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile or CV not found. Please update your profile.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationFormPage(
                          jobId: job['id']?.toString() ?? '',
                          applicantId: applicantId,
                          internshipTitle: title,
                          companyName: company,
                          cvUrl: cvUrl,
                        ),
                      ),
                    );
                  },
                  child: const Text("Apply Now"),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () async {
                  final jobId = job['id']?.toString();
                  if (jobId == null || jobId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job ID missing.')),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Saving internship...')),
                  );

                  final res =
                      await ApiService.saveInternshipWithStoredApplicant(
                        jobId: jobId,
                      );

                  messenger.hideCurrentSnackBar();
                  if (res['success'] == true) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Saved to your internships'),
                        backgroundColor: Colors.green, // success: green
                      ),
                    );
                  } else {
                    final code = res['code']?.toString();
                    final msg = code == 'ALREADY_SAVED'
                        ? 'This internship is already saved'
                        : (res['message']?.toString() ??
                              'Failed to save internship');
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.red, // error/already saved: red
                      ),
                    );
                  }
                },
                child: const Text("Save for Later"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class BulletList extends StatelessWidget {
  final List<String> items;
  const BulletList(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item)),
              ],
            ),
          )
          .toList(),
    );
  }
}

class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const BenefitItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
