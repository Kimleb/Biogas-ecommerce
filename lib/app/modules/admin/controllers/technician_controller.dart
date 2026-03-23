import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/technician_service.dart';
import '../../../data/models/technician_model.dart';

class TechnicianController extends GetxController {
  final isLightTheme = true.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final selectedTechnician = Rx<TechnicianModel?>(null);
  final isAddingTechnician = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final specializationController = TextEditingController();
  final locationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTechnicians();
  }

  /// Load all technicians
  Future<void> loadTechnicians() async {
    await TechnicianService.to.loadTechnicians();
  }

  /// Search technicians
  void searchTechnicians(String query) {
    searchQuery.value = query;
    TechnicianService.to.searchTechnicians(query);
  }

  /// Select technician
  void selectTechnician(TechnicianModel technician) {
    selectedTechnician.value = technician;
  }

  /// Clear selection
  void clearSelection() {
    selectedTechnician.value = null;
  }

  /// Add new technician
  Future<void> addTechnician() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isAddingTechnician.value = true;

      final technician = TechnicianModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        specialization: specializationController.text.trim(),
        location: locationController.text.trim(),
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      final success = await TechnicianService.to.addTechnician(technician);

      if (success) {
        // Clear form
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        specializationController.clear();
        locationController.clear();

        Get.snackbar(
          'Success',
          'Technician added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          TechnicianService.to.errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add technician: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAddingTechnician.value = false;
    }
  }

  /// Update technician availability
  Future<void> updateAvailability(String technicianId, bool isAvailable) async {
    try {
      final success = await TechnicianService.to
          .updateTechnicianAvailability(technicianId, isAvailable);

      if (success) {
        Get.snackbar(
          'Success',
          'Technician availability updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          TechnicianService.to.errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update availability: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Get available technicians
  List<TechnicianModel> get availableTechnicians =>
      TechnicianService.to.availableTechnicians;

  /// Get all technicians
  List<TechnicianModel> get technicians => TechnicianService.to.technicians;
}
