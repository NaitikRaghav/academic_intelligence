import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. 🟢 Live Stream with an IMMEDIATE check
final authStateProvider = StreamProvider<User?>((ref) async* {
  // 👇 THE MAGIC FIX: Immediately check if someone is logged in right now
  yield Supabase.instance.client.auth.currentUser;
  
  // Then listen to any future login/logout button presses
  yield* Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session?.user);
});

// 2. 🛠️ The Auth Service 
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Log In
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  // Log Out 
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

// 3. Expose the service to the rest of the app
final authServiceProvider = Provider<AuthService>((ref) => AuthService());