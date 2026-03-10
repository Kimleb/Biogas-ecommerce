import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/part_model.dart';
import '../../../data/dummy_data.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class BookingController extends GetxController {
  late ServiceModel service;
  final selectedParts = <PartModel>[].obs;
  final RxList<PartModel> availableParts = <PartModel>[].obs;
  final selectedDate = Rx<DateTime?>(null);
  final selectedTechnician = Rx<UserModel?>(null);
  final RxBool isLoadingParts = false.obs;

  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final AuthService _authService = AuthService.to;

  @override
  void onInit() {
    super.onInit();
    _loadPartsFromDatabase();

    // Check arguments immediately
    final args = Get.arguments;
    print('BookingController: Arguments received: $args');
    print('BookingController: Arguments type: ${args.runtimeType}');

    if (args is ServiceModel) {
      service = args;
      print('BookingController: Service loaded successfully: ${service.name}');
    } else {
      // Fallback to a default service or handle gracefully
      print('BookingController: No valid ServiceModel found, using fallback');
      service = ServiceModel(
        id: 'default',
        name: 'Unknown Service',
        description: '',
        images: [],
        thumbnailImages: [],
        duration: '30 min',
        price: 0.0,
        rating: 0.0,
        isActive: true,
      );
      // Optionally log or show a message
      print(
          'Warning: No ServiceModel passed to BookingController, using fallback');
    }

    // Check again after a small delay (in case arguments are not ready yet)
    Future.delayed(Duration(milliseconds: 100), () {
      final delayedArgs = Get.arguments;
      if (delayedArgs is ServiceModel && delayedArgs.id != 'default') {
        service = delayedArgs;
        print(
            'BookingController: Service loaded from delayed check: ${service.name}');
        update(); // Update UI
      }
    });
  }

  /// Load parts from Firebase database
  Future<void> _loadPartsFromDatabase() async {
    try {
      isLoadingParts.value = true;
      final partsData = await _databaseService.getAllParts();
      final parts = partsData.map((data) => PartModel.fromJson(data)).toList();
      availableParts.assignAll(parts);
      print('Loaded ${parts.length} parts from database');
    } catch (e) {
      print('Error loading parts: $e');
      // Fallback to dummy data if Firebase fails
      availableParts.assignAll(DummyData.parts);
    } finally {
      isLoadingParts.value = false;
    }
  }

  double get totalPrice {
    double partsTotal = selectedParts.fold(
        0, (sum, part) => sum + (part.price * part.quantity));
    return service.price + partsTotal;
  }

  void togglePart(PartModel part) {
    final index = selectedParts.indexWhere((p) => p.id == part.id);
    if (index >= 0) {
      selectedParts.removeAt(index);
    } else {
      // Add part with quantity 1
      selectedParts.add(part.copyWith(quantity: 1));
    }
  }

  void updatePartQuantity(String partId, int quantity) {
    final index = selectedParts.indexWhere((p) => p.id == partId);
    if (index >= 0 && quantity > 0) {
      selectedParts[index] = selectedParts[index].copyWith(quantity: quantity);
      selectedParts.refresh();
    }
  }

  bool isPartSelected(String partId) {
    return selectedParts.any((p) => p.id == partId);
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectTechnician(UserModel technician) {
    selectedTechnician.value = technician;
  }

  /// Method to manually set service (for debugging)
  void setService(ServiceModel newService) {
    service = newService;
    update(); // Update the UI
    print('BookingController: Service manually set: ${service.name}');
  }

  Future<void> confirmBooking() async {
    if (selectedDate.value == null) {
      Get.snackbar('Error', 'Please select a service date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      Get.snackbar(
        'Not signed in',
        'Please sign in again to confirm your booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: currentUser.id,
      customerName: currentUser.name,
      serviceId: service.id.toString(),
      serviceName: service.name,
      technicianId: selectedTechnician.value?.id,
      technicianName: selectedTechnician.value?.name,
      bookingDate: DateTime.now(),
      serviceDate: selectedDate.value!,
      status: 'pending',
      totalPrice: totalPrice,
      address: currentUser.address ?? 'No address provided',
      notes: '',
      selectedParts: selectedParts.toList(),
    );

    try {
      await _databaseService.addBooking(booking);

      Get.snackbar(
        'Success',
        'Booking confirmed! Proceed to payment to complete your order.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );

      Get.toNamed(Routes.PAYMENT, arguments: booking);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
