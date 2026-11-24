class CompanyModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String city;
  final String? district;
  final String state;
  final String industry;
  final DateTime createdAt;

  const CompanyModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.city,
    this.district,
    required this.state,
    required this.industry,
    required this.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      city: json['city'] as String,
      district: json['district'] as String?,
      state: json['state'] as String? ?? 'Maharashtra',
      industry: json['industry'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'city': city,
      'district': district,
      'state': state,
      'industry': industry,
    };
  }
}

class JobModel {
  final String id;
  final String companyId;
  final String title;
  final String category;
  final String jobType;
  final int vacancies;
  final String city;
  final String? district;
  final String state;
  final int minSalary;
  final int maxSalary;
  final String salaryType;
  final String minExperience;
  final String minEducation;
  final List<String> skillsRequired;
  final String description;
  final List<String> benefits;
  final String contactPerson;
  final bool isActive;
  final DateTime createdAt;
  final CompanyModel? company;

  const JobModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.category,
    required this.jobType,
    required this.vacancies,
    required this.city,
    this.district,
    required this.state,
    required this.minSalary,
    required this.maxSalary,
    required this.salaryType,
    required this.minExperience,
    required this.minEducation,
    required this.skillsRequired,
    required this.description,
    required this.benefits,
    required this.contactPerson,
    required this.isActive,
    required this.createdAt,
    this.company,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      jobType: json['job_type'] as String? ?? 'Full-time',
      vacancies: json['vacancies'] as int? ?? 1,
      city: json['city'] as String,
      district: json['district'] as String?,
      state: json['state'] as String? ?? 'Maharashtra',
      minSalary: json['min_salary'] as int,
      maxSalary: json['max_salary'] as int,
      salaryType: json['salary_type'] as String? ?? 'Monthly',
      minExperience: json['min_experience'] as String,
      minEducation: json['min_education'] as String,
      skillsRequired: List<String>.from(json['skills_required'] ?? []),
      description: json['description'] as String,
      benefits: List<String>.from(json['benefits'] ?? []),
      contactPerson: json['contact_person'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      company: json['companies'] != null ? CompanyModel.fromJson(json['companies']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'title': title,
      'category': category,
      'job_type': jobType,
      'vacancies': vacancies,
      'city': city,
      'district': district,
      'state': state,
      'min_salary': minSalary,
      'max_salary': maxSalary,
      'salary_type': salaryType,
      'min_experience': minExperience,
      'min_education': minEducation,
      'skills_required': skillsRequired,
      'description': description,
      'benefits': benefits,
      'contact_person': contactPerson,
      'is_active': isActive,
    };
  }

  String get salaryDisplay {
    final minFormatted = '₹${(minSalary / 1000).toStringAsFixed(minSalary % 1000 == 0 ? 0 : 1)}k';
    final maxFormatted = '₹${(maxSalary / 1000).toStringAsFixed(maxSalary % 1000 == 0 ? 0 : 1)}k';
    return '$minFormatted – $maxFormatted / month';
  }
}
