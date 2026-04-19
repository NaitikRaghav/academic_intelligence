import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core & Models
import '../../models/user_model.dart';
import '../../providers/mock_auth_provider.dart';

// Screens
import 'login_screen.dart';
import '../teacher/teacher_dashboard.dart';
import '../student/student_dashboard.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎧 Listen to our fake authentication state
    final mockUser = ref.watch(mockAuthStateProvider);

    // 🛑 If nobody is logged in, show the Login Screen
    if (mockUser == null) {
      return const LoginScreen();
    }

    // 🔀 The Routing Magic
    if (mockUser.role == UserRole.teacher) {
      return const TeacherDashboard(); 
    } else {
      return const StudentDashboard();
    }
  }
}