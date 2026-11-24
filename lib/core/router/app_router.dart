import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/shell/shell_screen.dart';
import '../../features/reels/reels_screen.dart';
import '../../features/jobs/search_jobs_screen.dart';
import '../../features/jobs/job_detail_screen.dart';
import '../../features/jobs/models/job_model.dart';
import '../../features/post/post_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/setup/profile_setup_screen.dart';
import '../../features/profile/models/candidate_profile_model.dart';
import '../../features/resume/resume_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/otp_verify_screen.dart';
import '../../features/applications/my_applications_screen.dart';
import '../../features/applications/employer_applicants_screen.dart';

// Tab index constants
const int kTabReels    = 0;
const int kTabJobs     = 1;
const int kTabPost     = 2;
const int kTabMessages = 3;
const int kTabProfile  = 4;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/reels',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reels',
                builder: (context, state) => const ReelsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const SearchJobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/post',
                builder: (context, state) => const PostScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerifyScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/resume',
        builder: (context, state) {
          final profile = state.extra as CandidateProfileModel;
          return ResumeScreen(profile: profile);
        },
      ),
      GoRoute(
        path: '/job-detail',
        builder: (context, state) {
          final job = state.extra as JobModel;
          return JobDetailScreen(job: job);
        },
      ),
      GoRoute(
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: '/employer-applicants',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EmployerApplicantsScreen(
            jobId: extra?['jobId'] as String?,
            jobTitle: extra?['jobTitle'] as String?,
          );
        },
      ),
    ],
  );
});
