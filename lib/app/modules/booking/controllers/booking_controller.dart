import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/part_model.dart';
import '../../../data/dummy_data.dart';

class BookingController extends GetxController {
  late ServiceModel service;
  final selectedParts = <PartModel>[].obs;
  final selectedDate = Rx<DateTime?>(null);
  final selectedTechnician = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ServiceModel) {
      service = args;
    } else {
      // Fallback to a default service or handle gracefully
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
      selectedParts.add(part);
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

  Future<void> confirmBooking() async {
    if (selectedDate.value == null) {
      Get.snackbar('Error', 'Please select a service date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final currentUser = DummyData.getCurrentUser();

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

    DummyData.bookings.add(booking);

    Get.snackbar(
      'Success',
      'Booking confirmed! We will contact you soon.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
    );

    Get.offAllNamed('/base');
  }
}
