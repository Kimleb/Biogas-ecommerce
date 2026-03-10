import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../../data/models/service_model.dart';
import '../../../data/services/firebase_manager.dart';

class CategoryController extends GetxController {
  final FirebaseDatabase _database = FirebaseManager.to.database;

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

      // Fetch all services and filter client-side to avoid index requirement
      print('Loading services for category: $categoryKey');
      final snapshot = await ref.get();
      print('Services snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Total services in database: ${data.keys.length}');

        for (final entry in data.entries) {
          try {
            final serviceData = Map<String, dynamic>.from(entry.value);
            final service = ServiceModel.fromJson(serviceData);
            print(
                'Service found: ${service.name}, category: ${service.category}, active: ${service.isActive}');

            // Filter by category and only add active services
            final serviceCategory = service.category?.toLowerCase() ?? '';
            final serviceName = service.name.toLowerCase();

            // Check if service matches the selected category
            bool matchesCategory = false;
            if (serviceCategory.isNotEmpty) {
              matchesCategory = serviceCategory == categoryKey;
            } else {
              // Fallback: match by service name if category is null
              if (categoryKey == 'installation' &&
                  serviceName.contains('install')) {
                matchesCategory = true;
              } else if (categoryKey == 'maintenance' &&
                  serviceName.contains('maintenance')) {
                matchesCategory = true;
              } else if (categoryKey == 'emergency' &&
                  serviceName.contains('emergency')) {
                matchesCategory = true;
              } else if (categoryKey == 'inspection' &&
                  serviceName.contains('inspection')) {
                matchesCategory = true;
              } else if (categoryKey == 'consultation' &&
                  serviceName.contains('consult')) {
                matchesCategory = true;
              } else if (categoryKey == 'training' &&
                  serviceName.contains('training')) {
                matchesCategory = true;
              }
            }

            if (service.isActive && matchesCategory) {
              print(
                  'Adding service: ${service.name} (matched by category: $serviceCategory or name: $serviceName)');
              services.add(service);
            } else {
              print(
                  'Skipping service: ${service.name} (category: $serviceCategory, active: ${service.isActive})');
            }
          } catch (e) {
            print('Error parsing service: $e');
          }
        }
        print('Services added to list: ${services.length}');
      } else {
        print('No services found in database');
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
      print('Loading all services from Firebase...');
      final snapshot = await ref.get();
      print('All services snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Total services in database: ${data.keys.length}');

        for (final entry in data.entries) {
          try {
            final serviceData = Map<String, dynamic>.from(entry.value);
            final service = ServiceModel.fromJson(serviceData);
            print(
                'Service found: ${service.name}, category: ${service.category}, active: ${service.isActive}');

            // Only add active services
            if (service.isActive) {
              print('Adding service: ${service.name}');
              services.add(service);
            }
          } catch (e) {
            print('Error parsing service: $e');
          }
        }
        print('Total services added to list: ${services.length}');
      } else {
        print('No services found in database');
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
