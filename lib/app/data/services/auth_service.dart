import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../dummy_data.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  User? get firebaseUser => _firebaseUser.value;
  UserModel? get currentUser => _currentUser.value;
  User? get user => _firebaseUser.value;
  Rx<User?> get userRx => _firebaseUser;
  bool get isSignedIn => _firebaseUser.value != null;
  bool get isAdmin => _currentUser.value?.role == 'admin';
  bool get isTechnician => _currentUser.value?.role == 'technician';
  bool get isCustomer => _currentUser.value?.role == 'customer';

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      await _loadUserData(user.uid);
      Get.offAllNamed('/base');
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final ref = _database.ref().child('users').child(uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _currentUser.value =
            UserModel.fromJson(Map<String, dynamic>.from(data));
        DummyData.setCurrentUser(_currentUser.value!);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> signUpWithEmail({
    required String emailAddress,
    required String password,
    required String name,
    required String phone,
    String role = 'customer',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          name: name,
          email: emailAddress,
          phone: phone,
          role: role,
        );

        await _database
            .ref()
            .child('users')
            .child(credential.user!.uid)
            .set(user.toJson());
        _currentUser.value = user;
        DummyData.setCurrentUser(user);

        Get.snackbar(
          'Success! 🎉',
          'Account created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for this email';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> signInWithEmail({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        Get.snackbar(
          'Welcome! 🎉',
          'Signed in successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();
      _currentUser.value = null;
      Get.snackbar(
        'Success',
        'Signed out successfully',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        Get.snackbar(
          'Cancelled',
          'Google Sign-In was cancelled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we got the tokens
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in database
        await _loadUserData(userCredential.user!.uid);

        // If user doesn't exist in database, create new user record
        if (_currentUser.value == null) {
          final user = UserModel(
            id: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? 'Google User',
            email: userCredential.user!.email ?? '',
            phone: userCredential.user!.phoneNumber ?? '',
            role: 'customer',
          );

          await _database
              .ref()
              .child('users')
              .child(userCredential.user!.uid)
              .set(user.toJson());
          _currentUser.value = user;
          DummyData.setCurrentUser(user);
        }

        Get.snackbar(
          'Success! 🎉',
          'Signed in with Google successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      String message = 'Google Sign-In failed';
      if (e.code == 'sign_in_failed') {
        message = 'Google Sign-In failed. Please try again.';
      } else if (e.code == 'network_error') {
        message = 'Network error. Please check your internet connection.';
      } else if (e.code == 'sign_in_canceled') {
        message = 'Sign-In was cancelled.';
      }

      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google Sign-In failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
