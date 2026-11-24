class CandidateProfileModel {
  final String id;
  final String fullName;
  final String phone;
  final String? photoUrl;
  final String workCategory;
  final String experienceYears;
  final String education;
  final List<String> skills;
  final String currentCity;
  final String? preferredCity;
  final String expectedSalary;
  final String? about;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CandidateProfileModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.photoUrl,
    required this.workCategory,
    required this.experienceYears,
    required this.education,
    required this.skills,
    required this.currentCity,
    this.preferredCity,
    required this.expectedSalary,
    this.about,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    return CandidateProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photo_url'] as String?,
      workCategory: json['work_category'] as String,
      experienceYears: json['experience_years'] as String,
      education: json['education'] as String,
      skills: List<String>.from(json['skills'] ?? []),
      currentCity: json['current_city'] as String,
      preferredCity: json['preferred_city'] as String?,
      expectedSalary: json['expected_salary'] as String,
      about: json['about'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'photo_url': photoUrl,
      'work_category': workCategory,
      'experience_years': experienceYears,
      'education': education,
      'skills': skills,
      'current_city': currentCity,
      'preferred_city': preferredCity,
      'expected_salary': expectedSalary,
      'about': about,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
