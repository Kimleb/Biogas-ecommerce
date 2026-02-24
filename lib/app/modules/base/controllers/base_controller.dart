import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class BaseController extends GetxController {
  // current screen index
  int currentIndex = 0;

  // to count the number of products in the cart
  int cartItemsCount = 0;

  // Get current user info
  String get userName => AuthService.to.user?.displayName ?? 'Guest';
  String get userEmail => AuthService.to.user?.email ?? '';
  bool get isUserSignedIn => AuthService.to.isSignedIn;
  bool get isAdmin => AuthService.to.isAdmin;

  @override
  void onInit() {
    getCartItemsCount();
    // Listen to authentication changes
    ever(AuthService.to.userRx, (_) {
      update(); // Update UI when auth state changes
    });
    super.onInit();
  }

  /// change the selected screen index
  changeScreen(int selectedIndex) {
    currentIndex = selectedIndex;
    update();
  }

  /// Navigate to admin dashboard if user is admin
  void navigateToAdmin() {
    if (isAdmin) {
      Get.toNamed(Routes.ADMIN_DASHBOARD);
    } else {
      Get.snackbar('Access Denied', 'You do not have admin privileges');
    }
  }

  /// calculate number of products in cart
  getCartItemsCount() {
    var products = DummyHelper.products;
    cartItemsCount = products.fold<int>(0, (p, c) {
      var product = c as Map<String, dynamic>;
      return p + (product['quantity'] as int? ?? 0);
    });
    update(['CartBadge']);
  }

  /// when user user press on add + icon
  onIncreasePressed(int productId) {
    var product = DummyHelper.products.firstWhere((p) => p['id'] == productId)
        as Map<String, dynamic>;
    product['quantity'] = (product['quantity'] as int? ?? 0) + 1;
    getCartItemsCount();
    update(['ProductQuantity']);
  }

  /// when user press on remove - icon
  onDecreasePressed(int productId) {
    var product = DummyHelper.products.firstWhere((p) => p['id'] == productId)
        as Map<String, dynamic>;
    int currentQuantity = product['quantity'] as int? ?? 0;
    if (currentQuantity > 0) {
      product['quantity'] = currentQuantity - 1;
      getCartItemsCount();
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().getCartProducts();
      }
      update(['ProductQuantity']);
    }
  }
}
