import 'package:flutter/cupertino.dart';

// Import our screens
import '../../screens/auth/login_screen.dart';
// We will uncomment these as we build them:
// import '../../screens/auth/signup_screen.dart';
// import '../../screens/student/student_dashboard.dart';
// import '../../screens/teacher/teacher_dashboard.dart';

class AppRoutes {
  // Define string constants for all routes to prevent typos
  static const String login = '/login';
  static const String signup = '/signup';
  static const String studentDashboard = '/student/dashboard';
  static const String teacherDashboard = '/teacher/dashboard';

  // The engine that intercepts navigation calls and returns the Cupertino-animated screen
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return CupertinoPageRoute(builder: (_) => const LoginScreen());
      
      // case signup:
      //   return CupertinoPageRoute(builder: (_) => const SignupScreen());
        
      default:
        // Fallback for unknown routes
        return CupertinoPageRoute(
          builder: (_) => CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Error 404'),
            ),
            child: Center(
              child: Text('Screen ${settings.name} not found.'),
            ),
          ),
        );
    }
  }
}