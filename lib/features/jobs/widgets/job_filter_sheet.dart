import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/jobs_provider.dart';

class JobFilterSheet extends ConsumerStatefulWidget {
  const JobFilterSheet({super.key});

  @override
  ConsumerState<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends ConsumerState<JobFilterSheet> {
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedExperience;
  String? _selectedJobType;

  final List<String> _categories = [
    'All',
    'Electrician',
    'Plumber',
    'Carpenter',
    'Welder/Fabricator',
    'Mason/Civil',
    'Painter',
    'Mechanic',
    'Driver',
    'Cook/Chef',
    'Security Guard',
    'Delivery/Courier'
  ];

  final List<String> _cities = [
    'All',
    'Pune',
    'Mumbai',
    'Nashik',
    'Nagpur',
    'Aurangabad',
    'Kolhapur',
    'Solapur'
  ];

  final List<String> _experiences = [
    'All',
    'Fresher',
    'Less than 1 yr',
    '1–2 yrs',
    '2–5 yrs',
    '5–10 yrs'
  ];

  final List<String> _jobTypes = [
    'All',
    'Full-time',
    'Part-time',
    'Contract'
  ];

  @override
  void initState() {
    super.initState();
    final f = ref.read(jobFilterProvider);
    _selectedCategory = f.category ?? 'All';
    _selectedCity = f.city ?? 'All';
    _selectedExperience = f.experience ?? 'All';
    _selectedJobType = f.jobType ?? 'All';
  }

  void _apply() {
    ref.read(jobFilterProvider.notifier).update((state) {
      return state.copyWith(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        clearCategory: _selectedCategory == 'All',
        city: _selectedCity == 'All' ? null : _selectedCity,
        clearCity: _selectedCity == 'All',
        experience: _selectedExperience == 'All' ? null : _selectedExperience,
        clearExperience: _selectedExperience == 'All',
        jobType: _selectedJobType == 'All' ? null : _selectedJobType,
        clearJobType: _selectedJobType == 'All',
      );
    });
    Navigator.pop(context);
  }

  void _reset() {
    ref.read(jobFilterProvider.notifier).update((state) {
      return const JobFilterState();
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Jobs', style: Theme.of(context).textTheme.headlineSmall),
                  TextButton(onPressed: _reset, child: const Text('Reset All')),
                ],
              ),
              const Divider(height: 20),

              // Category
              Text('Trade Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildWrapOptions(_categories, _selectedCategory, (val) {
                setState(() => _selectedCategory = val);
              }),
              const SizedBox(height: 16),

              // City
              Text('City / District', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildWrapOptions(_cities, _selectedCity, (val) {
                setState(() => _selectedCity = val);
              }),
              const SizedBox(height: 16),

              // Experience
              Text('Experience', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildWrapOptions(_experiences, _selectedExperience, (val) {
                setState(() => _selectedExperience = val);
              }),
              const SizedBox(height: 16),

              // Job Type
              Text('Job Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildWrapOptions(_jobTypes, _selectedJobType, (val) {
                setState(() => _selectedJobType = val);
              }),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _apply,
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWrapOptions(List<String> options, String? selected, ValueChanged<String> onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (_) => onSelected(opt),
          selectedColor: AppTheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
