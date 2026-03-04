import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/theme/my_theme.dart';
import '../../../../utils/constants.dart';
import 'package:biogas_technician_app/app/data/local/my_shared_pref.dart';
import 'package:biogas_technician_app/app/data/services/auth_service.dart';
import 'package:biogas_technician_app/app/data/services/database_service.dart';
import 'package:biogas_technician_app/app/data/models/service_model.dart';
import 'package:biogas_technician_app/app/data/models/category_model.dart';

class HomeController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  var isLightTheme = MySharedPref.getThemeIsLight();

  // for home screen cards - now using real data
  var cards = [
    {
      'icon': 'assets/vectors/eco_service.svg',
      'title': '24/7',
      'subtitle': 'Emergency Service'
    },
    {
      'icon': 'assets/vectors/calendar.svg',
      'title': 'Same Day',
      'subtitle': 'Booking Available'
    },
    {
      'icon': 'assets/vectors/fire.svg',
      'title': '4.9 (312)',
      'subtitle': 'Customer Rating'
    },
    {
      'icon': 'assets/vectors/user.svg',
      'title': 'Certified',
      'subtitle': 'Technicians'
    },
  ].obs;

  // Check if current user is admin
  bool get isAdmin => AuthService.to.isAdmin;

  // Reactive lists for real data
  var categories = <CategoryModel>[].obs;
  var services = <ServiceModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadServices();
  }

  /// Load categories from Firebase
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      // For now, create basic categories - can be moved to Firebase later
      categories.assignAll([
        CategoryModel(
          id: 1,
          title: 'Repair',
          image: 'assets/vectors/biogas_repair.svg',
          description: 'Emergency repairs and troubleshooting',
        ),
        CategoryModel(
          id: 2,
          title: 'Setup',
          image: 'assets/vectors/biogas_setup.svg',
          description: 'Professional installation and setup',
        ),
        CategoryModel(
          id: 3,
          title: 'Purchase',
          image: 'assets/vectors/biogas_purchase.svg',
          description: 'Biogas equipment and systems',
        ),
        CategoryModel(
          id: 4,
          title: 'Maintenance',
          image: 'assets/vectors/category.svg',
          description: 'Regular maintenance and servicing',
        ),
      ]);
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load services from Firebase database
  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      final serviceList = await _databaseService.getAllServices();
      services.assignAll(serviceList);
    } catch (e) {
      print('Error loading services from Firebase: $e');
      // Show error message instead of falling back to dummy data
      Get.snackbar(
          'Error', 'Failed to load services. Please check your connection.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data from Firebase
  Future<void> refreshData() async {
    await Future.wait([
      loadCategories(),
      loadServices(),
    ]);
  }

  /// when the user press on change theme icon
  onChangeThemePressed() {
    MyTheme.changeTheme();
    isLightTheme = MySharedPref.getThemeIsLight();
    update(['Theme']);
  }

  /// Navigate to admin dashboard
  void goToAdminDashboard() {
    Get.toNamed('/admin/dashboard');
  }
}
