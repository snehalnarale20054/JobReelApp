import '../profile/models/candidate_profile_model.dart';
import '../jobs/models/job_model.dart';

enum ApplicationStatus {
  applied,
  viewed,
  shortlisted,
  interview,
  selected,
  rejected;

  static ApplicationStatus fromString(String val) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ApplicationStatus.applied,
    );
  }

  String get displayName {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.viewed:
        return 'Viewed';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.selected:
        return 'Selected 🎉';
      case ApplicationStatus.rejected:
        return 'Not Selected';
    }
  }

  /// State Machine transition validation rules
  bool canTransitionTo(ApplicationStatus next) {
    if (this == next) return true;
    switch (this) {
      case ApplicationStatus.applied:
        return next == ApplicationStatus.viewed ||
            next == ApplicationStatus.shortlisted ||
            next == ApplicationStatus.rejected;
      case ApplicationStatus.viewed:
        return next == ApplicationStatus.shortlisted ||
            next == ApplicationStatus.interview ||
            next == ApplicationStatus.rejected;
      case ApplicationStatus.shortlisted:
        return next == ApplicationStatus.interview ||
            next == ApplicationStatus.selected ||
            next == ApplicationStatus.rejected;
      case ApplicationStatus.interview:
        return next == ApplicationStatus.selected ||
            next == ApplicationStatus.rejected;
      case ApplicationStatus.selected:
      case ApplicationStatus.rejected:
        return false; // Terminal states
    }
  }

  int get stepIndex {
    switch (this) {
      case ApplicationStatus.applied:
        return 0;
      case ApplicationStatus.viewed:
        return 1;
      case ApplicationStatus.shortlisted:
        return 2;
      case ApplicationStatus.interview:
        return 3;
      case ApplicationStatus.selected:
        return 4;
      case ApplicationStatus.rejected:
        return -1;
    }
  }
}

class ApplicationModel {
  final String id;
  final String jobId;
  final String candidateId;
  final ApplicationStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JobModel? job;
  final CandidateProfileModel? candidateProfile;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.job,
    this.candidateProfile,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      candidateId: json['candidate_id'] as String,
      status: ApplicationStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      job: json['jobs'] != null ? JobModel.fromJson(json['jobs']) : null,
      candidateProfile: json['candidate_profiles'] != null
          ? CandidateProfileModel.fromJson(json['candidate_profiles'])
          : null,
    );
  }
}
