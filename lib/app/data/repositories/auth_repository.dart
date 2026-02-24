import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// Repository layer for authentication operations
/// Follows clean architecture principles
class AuthRepository {
  final AuthService _authService = AuthService();

  // Getters
  UserModel? get currentUser => _authService.currentUser;
  User? get firebaseUser => _authService.firebaseUser;
  bool get isAuthenticated => _authService.isSignedIn;

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      return await _authService.signInWithEmail(
        emailAddress: email,
        password: password,
      );
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail(
      String email, String password, String name, String phone) async {
    try {
      return await _authService.signUpWithEmail(
        emailAddress: email,
        password: password,
        name: name,
        phone: phone,
      );
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      return await _authService.signInWithGoogle();
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// Load user data from database
  Future<void> loadUserData(String uid) async {
    try {
      // TODO: Implement proper user data loading through service
      // This will be handled by the service layer
    } catch (e) {
      throw AuthException('Failed to load user data: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserModel user) async {
    try {
      // Implementation for updating user profile
      return true;
    } catch (e) {
      throw AuthException('Profile update failed: ${e.toString()}');
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw AuthException('Account deletion failed: ${e.toString()}');
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
