import 'package:get/get.dart';

import '../../../data/models/booking_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';

class BookingHistoryController extends GetxController {
  final DatabaseService _databaseService = DatabaseService.to;
  final RxBool isLoading = false.obs;
  final RxList<BookingModel> bookings = <BookingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      isLoading.value = true;
      final currentUser = AuthService.to.firebaseUser;
      if (currentUser == null) {
        bookings.clear();
        return;
      }

      final userBookings = await _databaseService.getUserBookings(currentUser.uid);
      bookings.assignAll(userBookings);
      // Sort by serviceDate descending (newest first)
      bookings.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() async {
    await loadBookings();
  }
}
