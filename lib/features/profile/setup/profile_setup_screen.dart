import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../models/candidate_profile_model.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _prefCityController = TextEditingController();
  final _skillsController = TextEditingController();
  final _aboutController = TextEditingController();

  File? _imageFile;
  String? _uploadedPhotoUrl;
  bool _isSaving = false;

  // Selected dropdown / choice options
  String _workCategory = 'Electrician';
  String _experience = '1–2 yrs';
  String _education = '10th Pass (SSC)';
  String _expectedSalary = '₹15k–₹20k';

  final List<String> _workCategories = [
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
    'Agriculture',
    'Tailoring',
    'Other'
  ];

  final List<String> _experiences = [
    'Fresher',
    'Less than 1 yr',
    '1–2 yrs',
    '2–5 yrs',
    '5–10 yrs',
    '10+ yrs'
  ];

  final List<String> _educations = [
    '8th Pass',
    '10th Pass (SSC)',
    '12th Pass (HSC)',
    'ITI / Diploma',
    'Graduate',
    'Post Graduate',
    'Other'
  ];

  final List<String> _salaries = [
    'Below ₹5k',
    '₹5k–₹10k',
    '₹10k–₹15k',
    '₹15k–₹20k',
    '₹20k–₹30k',
    '₹30k+'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _prefCityController.dispose();
    _skillsController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_imageFile != null) {
        _uploadedPhotoUrl = await ref.read(profileProvider.notifier).uploadAvatar(_imageFile!);
      }

      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final profile = CandidateProfileModel(
        id: user.id,
        fullName: _nameController.text.trim(),
        phone: user.phone ?? '',
        photoUrl: _uploadedPhotoUrl,
        workCategory: _workCategory,
        experienceYears: _experience,
        education: _education,
        skills: skills.isEmpty ? [_workCategory] : skills,
        currentCity: _cityController.text.trim(),
        preferredCity: _prefCityController.text.trim().isEmpty
            ? _cityController.text.trim()
            : _prefCityController.text.trim(),
        expectedSalary: _expectedSalary,
        about: _aboutController.text.trim().isEmpty ? null : _aboutController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(profileProvider.notifier).saveProfile(profile);

      if (mounted) {
        context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        backgroundImage:
                            _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? const Icon(Icons.person, size: 52, color: AppTheme.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name *', hintText: 'e.g. Ramesh Kumar'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _workCategory,
                  decoration: const InputDecoration(labelText: 'Work Category *'),
                  items: _workCategories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _workCategory = val);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _experience,
                  decoration: const InputDecoration(labelText: 'Experience *'),
                  items: _experiences
                      .map((exp) => DropdownMenuItem(value: exp, child: Text(exp)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _experience = val);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _education,
                  decoration: const InputDecoration(labelText: 'Education *'),
                  items: _educations
                      .map((edu) => DropdownMenuItem(value: edu, child: Text(edu)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _education = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Current City/District *', hintText: 'e.g. Pune'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your current location' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prefCityController,
                  decoration: const InputDecoration(labelText: 'Preferred Work City', hintText: 'e.g. Mumbai or Any'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _expectedSalary,
                  decoration: const InputDecoration(labelText: 'Expected Monthly Salary *'),
                  items: _salaries
                      .map((sal) => DropdownMenuItem(value: sal, child: Text(sal)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _expectedSalary = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Skills (comma separated)',
                    hintText: 'e.g. Wiring, MCB, Inverter, Conduit',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aboutController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'About You (optional)',
                    hintText: 'Brief summary of your work or strengths',
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save & View Resume'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
