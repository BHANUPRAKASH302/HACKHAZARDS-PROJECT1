import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_method_screen.dart';
import '../../features/auth/verify_otp_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/learning/learning_screen.dart';
import '../../features/learning/course_detail_screen.dart';
import '../../features/learning/course_test_screen.dart';
import '../../data/mock/learning_mock.dart';
import '../../features/prescripto/prescripto_screen.dart';
import '../../features/prescripto/find_doctors_screen.dart';
import '../../features/prescripto/book_doctor_screen.dart';
import '../../features/prescripto/booked_appointments_screen.dart';
import '../../features/prescripto/medical_records_screen.dart';
import '../../features/prescripto/medicines_screen.dart';
import '../../features/prescripto/health_articles_screen.dart';
import '../../features/lawgen/lawgen_screen.dart';
import '../../features/lawgen/lawgen_chat_screen.dart';
import '../../features/lawgen/my_cases_screen.dart';
import '../../features/lawgen/legal_documents_screen.dart';
import '../../features/lawgen/law_library_screen.dart';
import '../../features/lawgen/consult_advocate_screen.dart';
import '../../features/agrogen/agrogen_screen.dart';
import '../../features/agrogen/crop_advisor_screen.dart';
import '../../features/agrogen/farm_details_screen.dart';
import '../../features/agrogen/pesticides_screen.dart';
import '../../features/agrogen/buy_products_screen.dart';
import '../../features/agrogen/gov_schemes_screen.dart';
import '../../features/agrogen/live_tracking_screen.dart';
import '../../features/safeguard/safeguard_screen.dart';
import '../../features/safeguard/sos_screen.dart';
import '../../features/safeguard/emergency_contacts_screen.dart';
import '../../features/safeguard/online_fir_screen.dart';
import '../../features/safeguard/view_fir_screen.dart';
import '../../features/safeguard/safety_tips_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/ai_assistance/ai_assistance_screen.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/profile/about_us_screen.dart';
import '../../features/profile/reviews_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/activity/mentor_feedback_screen.dart';
import '../services/auth_service.dart';

/// All app routes declared as constants to avoid typos.
abstract final class AppRoutes {
  static const splash         = '/';
  static const onboarding     = '/onboarding';
  static const login          = '/login';
  static const register       = '/register';
  static const verifyMethod   = '/verify-method';
  static const verifyOtp      = '/verify-otp';
  static const home           = '/home';
  static const learning       = '/learning';
  static const courseDetail   = '/learning/course';
  static const courseTest     = '/learning/course/test';
  static const prescripto     = '/prescripto';
  static const findDoctors    = '/prescripto/doctors';
  static const lawgen         = '/lawgen';
  static const lawgenChat     = '/lawgen/chat';
  static const myCases        = '/lawgen/my-cases';
  static const legalDocuments = '/lawgen/documents';
  static const lawLibrary     = '/lawgen/library';
  static const consultAdvocate = '/lawgen/consult-advocate';
  static const agrogen        = '/agrogen';
  static const cropAdvisor    = '/agrogen/crop';
  static const farmDetails    = '/agrogen/farm-details';
  static const pesticides     = '/agrogen/pesticides';
  static const buyProducts    = '/agrogen/buy-products';
  static const govSchemes     = '/agrogen/gov-schemes';
  static const liveTracking   = '/agrogen/live-tracking';
  static const safeguard      = '/safeguard';
  static const sos            = '/safeguard/sos';
  static const emergencyContacts = '/safeguard/contacts';
  static const onlineFir         = '/safeguard/online-fir';
  static const viewFir           = '/safeguard/view-fir';
  static const safetyTips        = '/safeguard/safety-tips';
  static const notifications  = '/notifications';
  static const profile        = '/profile';
  static const explore        = '/explore';
  static const aiAssistance   = '/ai-assistance';
  static const activity       = '/activity';
  static const aboutUs        = '/about-us';
  static const mentorFeedback = '/mentor-feedback';
  static const reviews        = '/reviews';
  static const settings       = '/settings';
}

/// Application router — go_router with auth redirect.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.verifyMethod ||
          state.matchedLocation == AppRoutes.verifyOtp;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.onboarding;
      if (isLoggedIn && (state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (c, s) => _fade(s, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (c, s) => _slide(s, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (c, s) => _slide(s, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (c, s) => _slide(s, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.verifyMethod,
        pageBuilder: (c, s) => _slide(s, const VerifyMethodScreen()),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        pageBuilder: (c, s) => _slide(s, const VerifyOtpScreen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (c, s) => _fade(s, const HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.learning,
        pageBuilder: (c, s) => _slide(s, const LearningScreen()),
      ),
      GoRoute(
        path: AppRoutes.courseDetail,
        pageBuilder: (c, s) {
          final course = s.extra as Course?;
          return _slide(s, CourseDetailScreen(course: course));
        },
      ),
      GoRoute(
        path: AppRoutes.courseTest,
        pageBuilder: (c, s) {
          final course = s.extra as Course;
          return _slide(s, CourseTestScreen(course: course));
        },
      ),
      GoRoute(
        path: AppRoutes.prescripto,
        pageBuilder: (c, s) => _slide(s, const PrescriptoScreen()),
      ),
      GoRoute(
        path: AppRoutes.findDoctors,
        pageBuilder: (c, s) => _slide(s, const FindDoctorsScreen()),
      ),
      GoRoute(
        path: '/prescripto/book',
        pageBuilder: (c, s) => _slide(s, BookDoctorScreen(doctor: s.extra as Map<String, dynamic>)),
      ),
      GoRoute(
        path: '/prescripto/bookings',
        pageBuilder: (c, s) => _slide(s, const BookedAppointmentsScreen())),
      GoRoute(
        path: '/prescripto/records',
        pageBuilder: (c, s) => _slide(s, const MedicalRecordsScreen())),
      GoRoute(
        path: '/prescripto/medicines',
        pageBuilder: (c, s) => _slide(s, const MedicinesScreen())),
      GoRoute(
        path: '/prescripto/articles',
        pageBuilder: (c, s) => _slide(s, const HealthArticlesScreen())),
      GoRoute(
        path: AppRoutes.lawgen,
        pageBuilder: (c, s) => _slide(s, const LawgenScreen()),
      ),
      GoRoute(
        path: AppRoutes.lawgenChat,
        pageBuilder: (c, s) => _slide(s, const LawgenChatScreen()),
      ),
      GoRoute(
        path: AppRoutes.myCases,
        pageBuilder: (c, s) => _slide(s, const MyCasesScreen()),
      ),
      GoRoute(
        path: AppRoutes.legalDocuments,
        pageBuilder: (c, s) => _slide(s, const LegalDocumentsScreen()),
      ),
      GoRoute(
        path: AppRoutes.lawLibrary,
        pageBuilder: (c, s) => _slide(s, const LawLibraryScreen()),
      ),
      GoRoute(
        path: AppRoutes.consultAdvocate,
        pageBuilder: (c, s) => _slide(s, const ConsultAdvocateScreen()),
      ),
      GoRoute(
        path: AppRoutes.agrogen,
        pageBuilder: (c, s) => _slide(s, const AgrogenScreen()),
      ),
      GoRoute(
        path: AppRoutes.cropAdvisor,
        pageBuilder: (c, s) => _slide(s, const CropAdvisorScreen()),
      ),
      GoRoute(
        path: AppRoutes.farmDetails,
        pageBuilder: (c, s) => _slide(s, const FarmDetailsScreen()),
      ),
      GoRoute(
        path: AppRoutes.pesticides,
        pageBuilder: (c, s) => _slide(s, const PesticidesScreen()),
      ),
      GoRoute(
        path: AppRoutes.buyProducts,
        pageBuilder: (c, s) => _slide(s, const BuyProductsScreen()),
      ),
      GoRoute(
        path: AppRoutes.govSchemes,
        pageBuilder: (c, s) => _slide(s, const GovSchemesScreen()),
      ),
      GoRoute(
        path: AppRoutes.liveTracking,
        pageBuilder: (c, s) => _slide(s, const LiveTrackingScreen()),
      ),
      GoRoute(
        path: AppRoutes.safeguard,
        pageBuilder: (c, s) => _slide(s, const SafeguardScreen()),
      ),
      GoRoute(
        path: AppRoutes.sos,
        pageBuilder: (c, s) => _slide(s, const SosScreen()),
      ),
      GoRoute(
        path: AppRoutes.emergencyContacts,
        pageBuilder: (c, s) => _slide(s, const EmergencyContactsScreen()),
      ),
      GoRoute(
        path: AppRoutes.onlineFir,
        pageBuilder: (c, s) => _slide(s, const OnlineFirScreen()),
      ),
      GoRoute(
        path: AppRoutes.viewFir,
        pageBuilder: (c, s) => _slide(s, const ViewFirScreen()),
      ),
      GoRoute(
        path: AppRoutes.safetyTips,
        pageBuilder: (c, s) => _slide(s, const SafetyTipsScreen()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (c, s) => _slide(s, const NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (c, s) => _slide(s, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.explore,
        pageBuilder: (c, s) => _fade(s, const ExploreScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiAssistance,
        pageBuilder: (c, s) => _fade(s, const AiAssistanceScreen()),
      ),
      GoRoute(
        path: AppRoutes.activity,
        pageBuilder: (c, s) => _fade(s, const ActivityScreen()),
      ),
      GoRoute(
        path: AppRoutes.aboutUs,
        pageBuilder: (c, s) => _slide(s, const AboutUsScreen()),
      ),
      GoRoute(
        path: AppRoutes.mentorFeedback,
        pageBuilder: (c, s) => _slide(s, const MentorFeedbackScreen()),
      ),
      GoRoute(
        path: AppRoutes.reviews,
        pageBuilder: (c, s) => _slide(s, const ReviewsScreen()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (c, s) => _slide(s, const SettingsScreen()),
      ),
    ],
  );
});

// ── Page Transition Builders ──────────────────────────────────────────────

CustomTransitionPage<T> _fade<T>(GoRouterState s, Widget child) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
    );

CustomTransitionPage<T> _slide<T>(GoRouterState s, Widget child) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, c) => SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: c,
      ),
    );
