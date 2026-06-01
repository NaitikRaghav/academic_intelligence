import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
import '../../providers/auth_provider.dart'; // 👈 Your real auth provider

// Screens
import 'login_screen.dart';
import '../teacher/teacher_dashboard.dart';
import '../student/student_dashboard.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎧 Listen to the live Supabase Auth Stream
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // ⏳ Loading State
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator(radius: 20)),
      ),
      // ❌ Error State
      error: (error, stack) => CupertinoPageScaffold(
        child: Center(child: Text('Error: $error')),
      ),
      // ✅ Data State (User is either logged in or null)
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        // 🔀 Temporary Routing: Until we pull the 'role' from the users table,
        // we will route based on email just to keep you unblocked!
        if (user.email != null && user.email!.toLowerCase().contains('teacher')) {
          return const TeacherDashboard(); 
        } else {
          return const StudentDashboard();
        }
      },
    );
  }
}