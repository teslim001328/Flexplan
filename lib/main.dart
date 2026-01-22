import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flexplan/models/goal.dart';
import 'package:flexplan/providers/goal_provider.dart';
import 'package:flexplan/services/auth_service.dart';
import 'package:flexplan/views/screens/create_goal_screen.dart';
import 'package:flexplan/views/screens/goal_details_screen.dart';
import 'package:flexplan/views/screens/analytics_screen.dart';
import 'package:flexplan/views/screens/home_screen.dart';
import 'package:flexplan/views/screens/login_screen.dart';
import 'package:flexplan/views/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flexplan/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminder();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
        ChangeNotifierProxyProvider<User?, GoalProvider>(
          create: (_) => GoalProvider('YOUR_AI_API_KEY'),
          update: (_, user, goalProvider) =>
              goalProvider!..setUserId(user?.uid),
        ),
      ],
      child: const FlexplanApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = context.read<User?>();
    final isLoggingIn = state.matchedLocation == '/login';
    final isSigningUp = state.matchedLocation == '/signup';

    if (user == null && !isLoggingIn && !isSigningUp) {
      return '/login';
    }
    if (user != null && (isLoggingIn || isSigningUp)) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/create-goal',
      builder: (context, state) => const CreateGoalScreen(),
    ),
    GoRoute(
      path: '/goal-details',
      builder: (context, state) {
        final goal = state.extra as Goal;
        return GoalDetailsScreen(goal: goal);
      },
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
  ],
);

class FlexplanApp extends StatelessWidget {
  const FlexplanApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    return MaterialApp.router(
      title: 'Flexplan',
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeedColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeedColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
