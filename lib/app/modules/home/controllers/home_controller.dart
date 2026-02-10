import 'package:get/get.dart';

import '../../../../config/theme/my_theme.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/dummy_helper.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../admin/views/admin_dashboard_view.dart';
import '../../admin/bindings/admin_binding.dart';

class HomeController extends GetxController {
  // to hold categories & services
  List<CategoryModel> categories = [];
  List<ServiceModel> services = [];

  // for app theme
  var isLightTheme = MySharedPref.getThemeIsLight();

  // for home screen cards
  var cards = DummyHelper.cards;

  // Check if current user is admin
  bool get isAdmin => AuthService.to.isAdmin;

  late final DatabaseService _databaseService;

  @override
  void onInit() {
    super.onInit();
    _databaseService = Get.find<DatabaseService>();
    getCategories();
    getServices();
  }

  /// get categories from dummy helper
  getCategories() {
    categories = DummyHelper.categories;
  }

  /// get services from database
  Future<void> getServices() async {
    try {
      services = await _databaseService.getAllServices();
      update(); // Trigger UI update
    } catch (e) {
      print('Error loading services: $e');
      // Fallback to dummy services if database fails
      services = DummyHelper.services;
      update();
    }
  }

  /// when the user press on change theme icon
  onChangeThemePressed() {
    MyTheme.changeTheme();
    isLightTheme = MySharedPref.getThemeIsLight();
    update(['Theme']);
  }

  /// Navigate to admin dashboard
  void goToAdminDashboard() {
    print('Admin button clicked - attempting navigation');
    try {
      Get.to(() => const AdminDashboardView(), binding: AdminBinding());
      print('Navigation command sent');
    } catch (e) {
      print('Navigation error: $e');
      Get.snackbar(
          'Navigation Error', 'Could not navigate to admin dashboard: $e');
    }
  }
}
