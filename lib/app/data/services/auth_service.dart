import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'firebase_manager.dart';
import '../../routes/app_pages.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseManager.to.database;
  GoogleSignIn? _googleSignIn;

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
    _initializeGoogleSignIn();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  void _initializeGoogleSignIn() {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
      print('Google Sign-In initialized successfully');
    } catch (e) {
      print('Error initializing Google Sign-In: $e');
      _googleSignIn = null;
    }
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      await _loadUserData(user.uid);

      // If user doesn't exist in database, prompt for additional details
      if (_currentUser.value == null) {
        final result = await _showUserDetailsDialog(user);
        if (result != null) {
          _currentUser.value = result;
          Get.offAllNamed(isAdmin ? Routes.ADMIN_DASHBOARD : Routes.BASE);
        } else {
          // User cancelled the details dialog, sign them out
          await _auth.signOut();
          if (_googleSignIn != null && _googleSignIn!.currentUser != null) {
            await _googleSignIn!.signOut();
          }
        }
      } else {
        Get.offAllNamed(isAdmin ? Routes.ADMIN_DASHBOARD : Routes.BASE);
      }
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
      } else {
        // User doesn't exist in database - this is okay for new users
        print('User not found in database, will create new user record');
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Don't throw error here, just log it - authentication can still succeed
    }
  }

  // Public method to refresh user data - can be called from external classes
  Future<void> refreshUserData() async {
    if (_firebaseUser.value != null) {
      await _loadUserData(_firebaseUser.value!.uid);
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

        // If user doesn't exist in database, prompt for additional details
        if (_currentUser.value == null) {
          final result = await _showUserDetailsDialog(credential.user!);
          if (result != null) {
            _currentUser.value = result;

            Get.snackbar(
              'Welcome! 🎉',
              'Profile completed successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return true;
          } else {
            // User cancelled the details dialog, sign them out
            await _auth.signOut();
            return false;
          }
        }

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
      if (_googleSignIn != null && _googleSignIn!.currentUser != null) {
        await _googleSignIn!.signOut();
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
      print('Starting Google Sign-In process...');

      // Check if Google Sign-In is initialized
      if (_googleSignIn == null) {
        print('Google Sign-In not initialized');
        Get.snackbar(
          'Error',
          'Google Sign-In is not available',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      print(
          'Google Sign-In result: ${googleUser != null ? "Success" : "Cancelled"}');

      if (googleUser == null) {
        // User cancelled the sign-in
        print('User cancelled Google Sign-In');
        Get.snackbar(
          'Cancelled',
          'Google Sign-In was cancelled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      print('Google user obtained: ${googleUser.displayName}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google authentication obtained');

      // Check if we got the tokens
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('No authentication tokens received');
        throw Exception('Failed to obtain Google authentication tokens');
      }

      print(
          'Access Token: ${googleAuth.accessToken != null ? "Present" : "Missing"}');
      print('ID Token: ${googleAuth.idToken != null ? "Present" : "Missing"}');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Firebase credential created');

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${userCredential.user?.displayName}');

      if (userCredential.user != null) {
        // Check if user exists in database
        print('Checking user database...');
        await _loadUserData(userCredential.user!.uid);
        print(
            'Database check complete. User found: ${_currentUser.value != null}');

        // If user doesn't exist in database, prompt for additional details
        if (_currentUser.value == null) {
          print('User not found in database, showing details dialog');
          final result = await _showUserDetailsDialog(userCredential.user!);
          if (result != null) {
            _currentUser.value = result;
            print('User details completed successfully');

            Get.snackbar(
              'Welcome! 🎉',
              'Account created successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return true;
          } else {
            print('User cancelled details dialog');
            // User cancelled the details dialog, sign them out
            await _auth.signOut();
            if (_googleSignIn != null) {
              await _googleSignIn!.signOut();
            }
            return false;
          }
        }

        print('User found in database, sign-in complete');
        Get.snackbar(
          'Welcome Back! 👋',
          'Signed in with Google successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      print('Firebase Auth Error Details: $e');

      String message = 'Google Sign-In failed';
      if (e.code == 'user-disabled') {
        message = 'This user account has been disabled';
      } else if (e.code == 'user-not-found') {
        message = 'User not found';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid Google credentials';
      } else if (e.code == 'account-exists-with-different-credential') {
        message = 'An account already exists with different credentials';
      } else {
        message = 'Firebase error: ${e.code} - ${e.message}';
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
      print('Exception: $e');

      String message = 'Google Sign-In failed';

      // Handle PlatformException (for Google Sign-In specific errors)
      if (e is PlatformException) {
        if (e.code == 'sign_in_failed') {
          message = 'Google Sign-In failed. Please try again.';
        } else if (e.code == 'network_error') {
          message = 'Network error. Please check your internet connection.';
        } else if (e.code == 'sign_in_canceled') {
          message = 'Sign-In was cancelled.';
        } else {
          message = 'Platform error: ${e.code} - ${e.message}';
        }
      } else {
        // Handle other generic exceptions
        message = 'An unexpected error occurred: $e';
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
      print('Google Sign-In Error Details: $e');
      print('Error Type: ${e.runtimeType}');
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

  Future<UserModel?> _showUserDetailsDialog(User firebaseUser) async {
    final nameController =
        TextEditingController(text: firebaseUser.displayName ?? '');
    final phoneController = TextEditingController();
    final roleController = TextEditingController(text: 'customer');

    return await Get.dialog<UserModel>(
      AlertDialog(
        title: Text('Complete Your Profile'),
        content: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please provide a few more details to complete your profile',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: 'customer',
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                items: [
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                ],
                onChanged: (value) {
                  roleController.text = value ?? 'customer';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please fill all required fields',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final user = UserModel(
                id: firebaseUser.uid,
                name: nameController.text.trim(),
                email: firebaseUser.email ?? '',
                phone: phoneController.text.trim(),
                role: roleController.text.trim(),
              );

              // Save user to database
              _database
                  .ref()
                  .child('users')
                  .child(firebaseUser.uid)
                  .set(user.toJson());

              Get.back(result: user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8C00),
            ),
            child:
                Text('Complete Profile', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
