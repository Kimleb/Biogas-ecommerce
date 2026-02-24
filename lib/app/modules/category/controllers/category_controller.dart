import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../../data/models/service_model.dart';

class CategoryController extends GetxController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Reactive variables
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = ''.obs;

  // Category mappings
  static const Map<String, String> categoryMappings = {
    'installation': 'installation',
    'maintenance': 'maintenance',
    'inspection': 'inspection',
    'consultation': 'consultation',
    'emergency': 'emergency',
    'training': 'training',
  };

  @override
  void onInit() {
    super.onInit();
  }

  /// Load services by category from database
  Future<void> loadServicesByCategory(String category) async {
    try {
      isLoading.value = true;
      selectedCategory.value = category;
      services.clear();

      final categoryKey =
          categoryMappings[category.toLowerCase()] ?? category.toLowerCase();
      final ref = _database.ref().child('services');

      // Query services by category
      final snapshot =
          await ref.orderByChild('category').equalTo(categoryKey).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        for (final entry in data.entries) {
          try {
            final serviceData = Map<String, dynamic>.from(entry.value);
            final service = ServiceModel.fromJson(serviceData);

            // Only add active services
            if (service.isActive) {
              services.add(service);
            }
          } catch (e) {
            print('Error parsing service: $e');
          }
        }
      }

      // Sort by rating (highest first)
      services.sort((a, b) => b.rating.compareTo(a.rating));
    } catch (e) {
      print('Error loading services by category: $e');
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get services for a specific category (non-reactive version)
  List<ServiceModel> getServicesForCategory(String category) {
    final categoryKey =
        categoryMappings[category.toLowerCase()] ?? category.toLowerCase();
    return services
        .where((service) =>
            service.category?.toLowerCase() == categoryKey.toLowerCase())
        .toList();
  }

  /// Refresh services for current category
  Future<void> refreshServices() async {
    if (selectedCategory.value.isNotEmpty) {
      await loadServicesByCategory(selectedCategory.value);
    }
  }

  /// Get all active services (fallback)
  Future<void> loadAllServices() async {
    try {
      isLoading.value = true;
      services.clear();

      final ref = _database.ref().child('services');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        for (final entry in data.entries) {
          try {
            final serviceData = Map<String, dynamic>.from(entry.value);
            final service = ServiceModel.fromJson(serviceData);

            // Only add active services
            if (service.isActive) {
              services.add(service);
            }
          } catch (e) {
            print('Error parsing service: $e');
          }
        }
      }

      // Sort by rating (highest first)
      services.sort((a, b) => b.rating.compareTo(a.rating));
    } catch (e) {
      print('Error loading all services: $e');
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
