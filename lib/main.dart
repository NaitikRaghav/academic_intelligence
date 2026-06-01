import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core Constants
import 'core/constants/colors.dart';

// Screens
import 'screens/auth/auth_wrapper.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready before doing any async setup
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 🟢 Ignite the Supabase Backend!
  await Supabase.initialize(
    url: 'https://sceyulspbddaursbkjcx.supabase.co', // 👈 Your backend partner will paste the URL here
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjZXl1bHNwYmRkYXVyc2JramN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2NjE1NTMsImV4cCI6MjA5MjIzNzU1M30.K3AVg4X0ojYl8iFVIIRcxIACwX83x3VcS3HDCw4JAkM', // 👈 Your backend partner will paste the Anon Key here
  );

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

      // 🚦 Our smart traffic controller that handles routing
      home: const AuthWrapper(), 
    );
  }
}