import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/auth_wrapper.dart';
import 'core/constants/colors.dart';



import 'screens/shared/ai_chat_screen.dart';
import 'screens/teacher/teacher_dashboard.dart';
import '../../screens/auth/login_screen.dart';
import 'screens/student/student_dashboard.dart';
void main() async {
  // 1. Ensure Flutter bindings are ready before doing any async setup
  WidgetsFlutterBinding.ensureInitialized();

  // 2. We will initialize Firebase right here in the next steps
  // await Firebase.initializeApp();

  // 3. Boot up the app wrapped in ProviderScope for Riverpod state management
  runApp(
    const ProviderScope(
      child: AcademicAIApp(),
    ),
  );
}

class AcademicAIApp extends StatelessWidget {
  const AcademicAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'AI Academic Intelligence',
      debugShowCheckedModeBanner: false, // Clean UI, no debug banner
      
      // 🎨 Injecting the "Hard" iOS Theme globally
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.surface, // Top nav bar color
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.textPrimary,
          // Cupertino automatically applies the native SF Pro font on Apple devices
        ),
      ),
      // We now point the app to our smart traffic controller


     //.........................................................there i have to add authwrapper for integration



      home: const AuthWrapper(), 
    );
  }
}

// 🚧 Temporary screen just so you can run the app and see the theme working
class PlaceholderBootScreen extends StatelessWidget {
  const PlaceholderBootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Academic AI System'),
        backgroundColor: AppColors.surfaceElevated,
        border: null, // Removes the bottom border for a cleaner look
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.sparkles, // AI Brain Icon
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'System Initialized',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5, // Tighter letter spacing for iOS feel
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Awaiting Auth UI...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}