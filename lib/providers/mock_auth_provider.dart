import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// 1. Holds the current fake user state (null = logged out)
final mockAuthStateProvider = StateProvider<UserModel?>((ref) => null);

// 2. Simulates the Firebase Auth Service
class MockAuthService {
  final Ref ref;
  MockAuthService(this.ref);

  Future<void> signIn({required String email, required String password}) async {
    // Simulate network delay to show off your premium loading button
    await Future.delayed(const Duration(seconds: 2));

    // Smart Routing Logic: 
    // If they type "student@test.com", make them a student. Otherwise, teacher.
    UserRole role = email.toLowerCase().contains('student') 
        ? UserRole.student 
        : UserRole.teacher;

    // "Log them in" by saving the fake user to our state
    ref.read(mockAuthStateProvider.notifier).state = UserModel(
      id: 'mock_user_999',
      name: 'Mock User',
      email: email,
      role: role,
      createdAt: DateTime.now(), // 👈 ADD THIS LINE
    );
  }

  void signOut() {
    // "Log them out" by clearing the state
    ref.read(mockAuthStateProvider.notifier).state = null;
  }
}

// 3. The provider we will use in our UI
final mockAuthServiceProvider = Provider((ref) => MockAuthService(ref));