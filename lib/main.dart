import 'package:firebase_core/firebase_core.dart';
import 'package:flexplan/models/goal.dart';
import 'package:flexplan/providers/goal_provider.dart';
import 'package:flexplan/views/screens/create_goal_screen.dart';
import 'package:flexplan/views/screens/goal_details_screen.dart';
import 'package:flexplan/views/screens/analytics_screen.dart';
import 'package:flexplan/views/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: Firebase initialization will fail if firebase_options.dart is missing.
  // I'll wrap it in a try-catch for now to allow development of other parts.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              GoalProvider('YOUR_AI_API_KEY'), // User will need to add this
        ),
      ],
      child: const FlexplanApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
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
    final Color primarySeedColor = Colors.deepPurple;

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
