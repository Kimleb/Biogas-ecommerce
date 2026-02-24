import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  GetPage? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Check if user is authenticated
    if (!authService.isSignedIn) {
      return GetPage(name: '/login', page: () => Container());
    }

    // Check if user is admin
    if (!authService.isAdmin) {
      // Redirect non-admin users to home
      return GetPage(name: '/home', page: () => Container());
    }

    // Allow admin access
    return null;
  }
}
