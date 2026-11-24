import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../auth/providers/auth_provider.dart';
import '../jobs/providers/jobs_provider.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _minSalaryController = TextEditingController(text: '15000');
  final _maxSalaryController = TextEditingController(text: '22000');
  final _vacanciesController = TextEditingController(text: '2');
  final _skillsController = TextEditingController();
  final _descController = TextEditingController();
  final _contactController = TextEditingController();

  String _category = 'Electrician';
  String _jobType = 'Full-time';
  String _minExp = '1–2 yrs';
  String _minEdu = '10th Pass (SSC)';

  final Set<String> _selectedBenefits = {'PF & ESIC'};

  bool _isPosting = false;

  final List<String> _categories = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Welder/Fabricator',
    'Mason/Civil',
    'Painter',
    'Mechanic',
    'Driver',
    'Security Guard',
    'Cook/Chef',
    'Housekeeping',
    'Helper/Labour',
    'Delivery/Courier',
    'Other'
  ];

  final List<String> _experiences = [
    'Fresher',
    'Less than 1 yr',
    '1–2 yrs',
    '2–5 yrs',
    '5–10 yrs'
  ];

  final List<String> _educations = [
    '8th Pass',
    '10th Pass (SSC)',
    '12th Pass (HSC)',
    'ITI / Diploma',
    'Graduate'
  ];

  final List<String> _benefitsList = [
    'PF & ESIC',
    'Free Food / Canteen',
    'Accommodation',
    'Overtime Pay',
    'Transport / Bus',
    'Weekly Off'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _companyNameController.dispose();
    _cityController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _vacanciesController.dispose();
    _skillsController.dispose();
    _descController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submitJob() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign in first to post a job!'),
          action: SnackBarAction(label: 'Sign In', onPressed: () => context.push('/auth')),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Ensure minimal company profile exists for employer
      final companyName = _companyNameController.text.trim();
      final city = _cityController.text.trim();

      await supabase.from('companies').upsert({
        'id': user.id,
        'name': companyName,
        'city': city,
        'state': 'Maharashtra',
        'industry': _category,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Insert new Job
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await supabase.from('jobs').insert({
        'company_id': user.id,
        'title': _titleController.text.trim(),
        'category': _category,
        'job_type': _jobType,
        'vacancies': int.tryParse(_vacanciesController.text.trim()) ?? 1,
        'city': city,
        'state': 'Maharashtra',
        'min_salary': int.tryParse(_minSalaryController.text.trim()) ?? 10000,
        'max_salary': int.tryParse(_maxSalaryController.text.trim()) ?? 15000,
        'salary_type': 'Monthly',
        'min_experience': _minExp,
        'min_education': _minEdu,
        'skills_required': skills.isEmpty ? [_category] : skills,
        'description': _descController.text.trim(),
        'benefits': _selectedBenefits.toList(),
        'contact_person': _contactController.text.trim(),
        'is_active': true,
      });

      ref.refresh(jobsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.go('/jobs');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post job: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post a Job')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.business_center_outlined, size: 72, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Post Free Jobs & Hire Workers',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  '100% Free. Reach thousands of skilled blue-collar candidates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Sign In as Employer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job (2 min)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Employer & Job Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company / Business Name *', hintText: 'e.g. Sai Fabrication Works'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter company name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title *', hintText: 'e.g. Experienced House Electrician'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter job title' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Trade Category *'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Job City *', hintText: 'e.g. Pune'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _vacanciesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Vacancies *', hintText: 'e.g. 5'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minSalaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min Monthly (₹) *'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxSalaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max Monthly (₹) *'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _minExp,
                      decoration: const InputDecoration(labelText: 'Experience *'),
                      items: _experiences.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _minExp = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _minEdu,
                      decoration: const InputDecoration(labelText: 'Education *'),
                      items: _educations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _minEdu = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(labelText: 'Required Skills', hintText: 'e.g. Wiring, MCB, Inverter (comma-separated)'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Person / HR Name *', hintText: 'e.g. Ramesh Patil (Manager)'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter contact person' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Job Description *', hintText: 'Working hours, address or duties'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter job description' : null,
              ),
              const SizedBox(height: 16),
              Text('Benefits & Perks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _benefitsList.map((benefit) {
                  final isSelected = _selectedBenefits.contains(benefit);
                  return FilterChip(
                    label: Text(benefit),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedBenefits.add(benefit);
                        } else {
                          _selectedBenefits.remove(benefit);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isPosting ? null : _submitJob,
                child: _isPosting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Post Free Job Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
