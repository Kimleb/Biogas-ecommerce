import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;
  final CloudinaryService _cloudinaryService = CloudinaryService.to;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    if (_authService.currentUser != null) {
      currentUser.value = _authService.currentUser;
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    try {
      isLoading.value = true;

      if (currentUser.value == null) {
        Get.snackbar(
          'Error',
          'User data not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Generate thumbnail URL
      final thumbnailUrl = _cloudinaryService.getThumbnailUrl(
        imageUrl,
        width: 200,
        height: 200,
      );

      // Update user model with new image
      final updatedUser = currentUser.value!.copyWith(
        profileImage: imageUrl,
        thumbnailImage: thumbnailUrl,
        updatedAt: DateTime.now(),
      );

      // Update in Firebase
      await _updateUserInDatabase(updatedUser);

      // Update local state
      currentUser.value = updatedUser;

      Get.snackbar(
        'Success',
        'Profile picture updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile picture: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;

      // Update in Firebase
      await _updateUserInDatabase(updatedUser);

      // Update local state
      currentUser.value = updatedUser;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateUserInDatabase(UserModel user) async {
    try {
      final DatabaseReference userRef = _database.ref('users/${user.id}');
      await userRef.update(user.toJson());

      // Also update in AuthService
      await _authService.refreshUserData();
    } catch (e) {
      throw Exception('Database update failed: $e');
    }
  }

  Future<void> refreshUserData() async {
    try {
      if (_authService.firebaseUser != null) {
        await _authService.refreshUserData();
        _loadUserData();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh user data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
