import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/booking_model.dart';

class AdminController extends GetxController {
  late final DatabaseService _databaseService;

  final services = <ServiceModel>[].obs;
  final bookings = <BookingModel>[].obs;
  final parts = <PartModel>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs;

  // Form controllers for adding/editing services
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final technicianController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Initialize DatabaseService after onInit
    _databaseService = Get.find<DatabaseService>();
    loadData();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    durationController.dispose();
    technicianController.dispose();
    super.onClose();
  }

  void loadData() {
    isLoading.value = true;

    // Load initial data
    loadServices();
    loadBookings();
    loadParts();

    isLoading.value = false;
  }

  Future<void> loadServices() async {
    try {
      services.value = await _databaseService.getAllServices();
    } catch (e) {
      print('Error loading services: $e');
    }
  }

  Future<void> loadBookings() async {
    try {
      bookings.value = await _databaseService.getAllBookings();
    } catch (e) {
      print('Error loading bookings: $e');
    }
  }

  Future<void> loadParts() async {
    try {
      final partsData = await _databaseService.getAllParts();
      parts.value = partsData.map((data) => PartModel.fromJson(data)).toList();
    } catch (e) {
      print('Error loading parts: $e');
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Service Management
  Future<void> addService() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final service = ServiceModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: nameController.text,
        description: descriptionController.text,
        price: double.parse(priceController.text),
        duration: durationController.text,
        image: '', // Remove placeholder image for now
        technician: technicianController.text,
        rating: 0.0,
      );

      await _databaseService.addService(service);

      Get.back();
      Get.snackbar('Success', 'Service added successfully',
          backgroundColor: Colors.green, colorText: Colors.white);

      clearForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add service: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      await _databaseService.updateService(service);
      Get.snackbar('Success', 'Service updated successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update service: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _databaseService.deleteService(serviceId);
      Get.snackbar('Success', 'Service deleted successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete service: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Booking Management
  Future<void> updateBookingStatus(
      BookingModel booking, String newStatus) async {
    try {
      final updatedBooking = BookingModel(
        id: booking.id,
        customerId: booking.customerId,
        customerName: booking.customerName,
        serviceId: booking.serviceId,
        serviceName: booking.serviceName,
        technicianId: booking.technicianId,
        technicianName: booking.technicianName,
        bookingDate: booking.bookingDate,
        serviceDate: booking.serviceDate,
        status: newStatus,
        totalPrice: booking.totalPrice,
        address: booking.address,
        notes: booking.notes,
        selectedParts: booking.selectedParts,
        rating: booking.rating,
        review: booking.review,
      );

      await _databaseService.updateBooking(updatedBooking);
      Get.snackbar('Success', 'Booking status updated',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update booking: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _databaseService.deleteBooking(bookingId);
      Get.snackbar('Success', 'Booking deleted successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete booking: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    durationController.clear();
    technicianController.clear();
  }

  void showAddServiceDialog() {
    clearForm();
    Get.dialog(
      AlertDialog(
        title: Text('Add New Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Service Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Duration'),
              ),
              TextField(
                controller: technicianController,
                decoration: InputDecoration(labelText: 'Technician'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: addService,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
