import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 🎧 Listen to live authentication state changes
  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  /// 🚪 Sign In
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// 📝 Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String name,
  }) async {
    try {
      // 1. Create the user in Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Sign up failed.');

      // 2. Save their role and metadata to your public 'users' table
      final userModel = UserModel(
        id: user.id,
        name: name,
        email: email,
        role: role,
        avatarUrl: null, // 👈 Explicitly null until they upload a profile picture
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // 👈 ADDED: Matches your new PostgreSQL schema!
      );

      await _supabase.from('users').insert(userModel.toMap());

    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  /// 🏃‍♂️ Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}