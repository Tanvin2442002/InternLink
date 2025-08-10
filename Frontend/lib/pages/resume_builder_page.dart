import 'package:flutter/material.dart';

class ResumeBuilderPage extends StatefulWidget {
  const ResumeBuilderPage({super.key});
  @override
  State<ResumeBuilderPage> createState() => _ResumeBuilderPageState();
}

class _ResumeBuilderPageState extends State<ResumeBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _summary = TextEditingController();
  final List<_ExperienceEntry> _experience = [];
  final List<String> _skills = [];
  final _skillCtrl = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _summary.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Resume Builder'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportDialog,
            tooltip: 'Export (Mock)',
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16,16,16,120),
          children: [
            _sectionTitle('Basic Info'),
            TextFormField(
              controller: _name,
              decoration: _input('Full Name'),
              validator: (v)=> v==null||v.isEmpty? 'Required': null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _role,
              decoration: _input('Target Role (e.g. Flutter Intern)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _summary,
              maxLines: 4,
              decoration: _input('Professional Summary'),
            ),
            const SizedBox(height: 28),
            _sectionTitle('Experience'),
            ..._experience.map((e)=> _experienceTile(e)).toList(),
            TextButton.icon(
              onPressed: _addExperienceDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Experience'),
            ),
            const SizedBox(height: 28),
            _sectionTitle('Skills'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((s)=> Chip(
                label: Text(s),
                onDeleted: ()=> setState(()=> _skills.remove(s)),
                deleteIcon: const Icon(Icons.close, size: 16),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(children:[
              Expanded(
                child: TextField(
                  controller: _skillCtrl,
                  decoration: _input('Add skill'),
                  onSubmitted: (_)=> _addSkill(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addSkill,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Add'),
              )
            ]),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _generatePreview,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text('Generate Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _aiImprove,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: const Text('AI Improve', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
  );

  void _addSkill() {
    final v = _skillCtrl.text.trim();
    if(v.isEmpty) return;
    if(!_skills.contains(v)) setState(()=> _skills.add(v));
    _skillCtrl.clear();
  }

  void _generatePreview() {
    if(!_formKey.currentState!.validate()) return;
    final preview = _buildResumePreview();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .85,
        maxChildSize: .95,
        minChildSize: .6,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.fromLTRB(24,16,24,32),
          child: ListView(
            controller: controller,
            children: [
              Row(children:[
                const Icon(Icons.description, color: Colors.deepPurple),
                const SizedBox(width: 12),
                const Text('Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close))
              ]),
              const SizedBox(height: 12),
              preview,
            ],
          ),
        ),
      ),
    );
  }

  void _aiImprove() {
    if(_summary.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a summary first.')));
      return;
    }
    setState(() {
      _summary.text = '${_summary.text.trim()}\n\nOptimized: Focused on delivering performant, accessible Flutter UI and collaborative feature delivery.';
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied AI improvement (demo).')));
  }

  void _exportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export'),
        content: const Text('PDF export not implemented. Integrate a PDF package (e.g. printing / pdf) later.'),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close'))
        ],
      ),
    );
  }

  void _addExperienceDialog() {
    final company = TextEditingController();
    final title = TextEditingController();
    final desc = TextEditingController();
    final period = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20,20,20,32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(controller: title, decoration: _input('Role Title')),
              const SizedBox(height: 12),
              TextField(controller: company, decoration: _input('Company')),
              const SizedBox(height: 12),
              TextField(controller: period, decoration: _input('Period (e.g. Jun 24 - Aug 24)')),
              const SizedBox(height: 12),
              TextField(controller: desc, maxLines: 4, decoration: _input('Description / Impact (bullet style)')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if(title.text.trim().isEmpty) return; 
                    setState(()=> _experience.add(_ExperienceEntry(company: company.text.trim(), title: title.text.trim(), desc: desc.text.trim(), period: period.text.trim())));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _experienceTile(_ExperienceEntry e) => Dismissible(
    key: ValueKey(e),
    background: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    direction: DismissDirection.endToStart,
    onDismissed: (_){ setState(()=> _experience.remove(e)); },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8, offset: const Offset(0,4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('${e.company} • ${e.period}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        if(e.desc.isNotEmpty) Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(e.desc, style: const TextStyle(fontSize: 12, height: 1.3)),
        )
      ]),
    ),
  );

  Widget _buildResumePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_name.text.trim(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        if(_role.text.trim().isNotEmpty) Text(_role.text.trim(), style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        const SizedBox(height: 14),
        if(_summary.text.trim().isNotEmpty) Text(_summary.text.trim(), style: const TextStyle(height: 1.35)),
        const SizedBox(height: 22),
        if(_experience.isNotEmpty)...[
          const Text('Experience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ..._experience.map((e)=> Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${e.company} • ${e.period}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              if(e.desc.isNotEmpty) Padding(padding: const EdgeInsets.only(top:4), child: Text(e.desc, style: const TextStyle(fontSize: 12, height: 1.3))),
            ]),
          )),
          const SizedBox(height: 18),
        ],
        if(_skills.isNotEmpty)...[
          const Text('Skills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: _skills.map((s)=> Chip(label: Text(s))).toList()),
        ]
      ],
    );
  }
}

class _ExperienceEntry {
  final String company; final String title; final String desc; final String period; _ExperienceEntry({required this.company, required this.title, required this.desc, required this.period});
}
