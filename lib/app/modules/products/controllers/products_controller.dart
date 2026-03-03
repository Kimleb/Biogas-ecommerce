import 'package:get/get.dart';

import '../../../data/models/service_model.dart';
import '../../../data/services/database_service.dart';

class ProductsController extends GetxController {
  // to hold services
  List<ServiceModel> services = [];
  final isLoading = false.obs;
  late final DatabaseService _databaseService;

  @override
  void onInit() {
    super.onInit();
    _databaseService = Get.find<DatabaseService>();
    getServices();
  }

  /// get services from database
  Future<void> getServices() async {
    try {
      isLoading.value = true;
      services = await _databaseService.getAllServices();
      update();
    } catch (e) {
      services = [];
      update();
    } finally {
      isLoading.value = false;
    }
  }
}
