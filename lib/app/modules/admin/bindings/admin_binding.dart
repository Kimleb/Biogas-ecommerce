import 'package:get/get.dart';

import '../../../data/services/database_service.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // DatabaseService is already created in main.dart
    // Just use the existing instance
    Get.find<DatabaseService>();

    Get.lazyPut<AdminController>(
      () => AdminController(),
    );
  }
}
