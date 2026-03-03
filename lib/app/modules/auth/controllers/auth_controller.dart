import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoginMode = true.obs;
  final RxBool acceptTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  Future<void> onLogin() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final success = await AuthService.to.signInWithEmail(
        emailAddress: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        // Navigation is handled by AuthService authState listener
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onSignup() async {
    if (!signupFormKey.currentState!.validate()) return;

    if (!acceptTerms.value) {
      Get.snackbar(
        'Error',
        'Please accept the terms and conditions',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final success = await AuthService.to.signUpWithEmail(
        emailAddress: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (success) {
        // Navigation is handled by AuthService authState listener
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Signup failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onForgotPassword() {
    Get.snackbar(
      'Coming Soon',
      'Password reset feature will be available soon.',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  Future<void> onGoogleSignIn() async {
    isLoading.value = true;

    try {
      final success = await AuthService.to.signInWithGoogle();

      if (success) {
        // Navigation is handled by AuthService authState listener
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google Sign-In failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
