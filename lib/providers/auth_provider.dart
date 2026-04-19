import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// 1. Expose the AuthService globally so any screen can trigger login/signup without creating new instances
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 2. Stream the user's live authentication state (Logged in vs Logged out)
// By listening to this, our app's Router can automatically switch screens securely
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});