import 'package:get/get.dart';

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

  /// calculate number of products in cart from cart controller
  getCartItemsCount() {
    if (Get.isRegistered<CartController>()) {
      cartItemsCount = Get.find<CartController>().totalItems;
    } else {
      cartItemsCount = 0;
    }
    update(['CartBadge']);
  }

  /// when user press on add + icon - delegate to cart controller
  onIncreasePressed(String serviceId) {
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().onIncreasePressed(serviceId);
      getCartItemsCount();
    }
    update(['ProductQuantity']);
  }

  /// when user press on remove - icon - delegate to cart controller
  onDecreasePressed(String serviceId) {
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().onDecreasePressed(serviceId);
      getCartItemsCount();
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().getCartProducts();
      }
    }
    update(['ProductQuantity']);
  }
}
