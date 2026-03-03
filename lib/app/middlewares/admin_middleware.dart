import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../routes/app_pages.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  GetPage? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Check if user is authenticated
    if (!authService.isSignedIn) {
      return GetPage(name: Routes.LOGIN, page: _EmptyPage.new);
    }

    // Check if user is admin
    if (!authService.isAdmin) {
      // Redirect non-admin users to home
      return GetPage(name: Routes.BASE, page: _EmptyPage.new);
    }

    // Allow admin access
    return null;
  }
}

class _EmptyPage extends StatelessWidget {
  const _EmptyPage({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
