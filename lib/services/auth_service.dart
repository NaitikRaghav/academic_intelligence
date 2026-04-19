import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📡 Stream to listen to auth state changes (logged in vs logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 👤 Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 🚀 Sign Up (Creates Auth account AND Firestore user document)
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // 1. Create the user in Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user != null) {
        // 2. Create our custom UserModel blueprint
        final newUser = UserModel(
          id: user.uid,
          name: name.trim(),
          email: email.trim(),
          role: role,
          createdAt: DateTime.now(),
        );

        // 3. Save this blueprint to the Firestore 'users' collection
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // 🚨 Standardized error handling for the UI to display
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  // 🔑 Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user != null) {
        // Fetch the user's full profile from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  // 🚪 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🛠️ Helper to translate cryptic Firebase codes into human-readable text
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}