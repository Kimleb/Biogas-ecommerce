import 'package:get/get.dart';

import '../../../data/services/database_service.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DatabaseService is available
    if (!Get.isRegistered<DatabaseService>()) {
      Get.put<DatabaseService>(DatabaseService());
    }

    Get.lazyPut<AdminController>(
      () => AdminController(),
    );
  }
}
