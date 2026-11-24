import 'package:flutter_test/flutter_test.dart';
import 'package:job_reels/features/applications/models/application_model.dart';

void main() {
  group('Application Status State Machine Tests', () {
    test('Initial applied state can transition to viewed, shortlisted, and rejected', () {
      const status = ApplicationStatus.applied;
      expect(status.canTransitionTo(ApplicationStatus.viewed), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.shortlisted), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.rejected), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.selected), isFalse);
    });

    test('Viewed state can transition to shortlisted, interview, or rejected', () {
      const status = ApplicationStatus.viewed;
      expect(status.canTransitionTo(ApplicationStatus.shortlisted), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.interview), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.rejected), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.selected), isFalse);
    });

    test('Shortlisted state can transition to interview, selected, or rejected', () {
      const status = ApplicationStatus.shortlisted;
      expect(status.canTransitionTo(ApplicationStatus.interview), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.selected), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.rejected), isTrue);
    });

    test('Interview state can transition to selected or rejected', () {
      const status = ApplicationStatus.interview;
      expect(status.canTransitionTo(ApplicationStatus.selected), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.rejected), isTrue);
      expect(status.canTransitionTo(ApplicationStatus.shortlisted), isFalse);
    });

    test('Selected and Rejected are terminal states', () {
      const selected = ApplicationStatus.selected;
      expect(selected.canTransitionTo(ApplicationStatus.rejected), isFalse);
      expect(selected.canTransitionTo(ApplicationStatus.interview), isFalse);

      const rejected = ApplicationStatus.rejected;
      expect(rejected.canTransitionTo(ApplicationStatus.applied), isFalse);
      expect(rejected.canTransitionTo(ApplicationStatus.selected), isFalse);
    });
  });
}
