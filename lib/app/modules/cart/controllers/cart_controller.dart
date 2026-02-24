import 'package:get/get.dart';

import '../../../../utils/dummy_helper.dart';
import '../../../components/custom_snackbar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/service_model.dart';
import '../../base/controllers/base_controller.dart';

class CartController extends GetxController {
  // to hold the services in cart
  List<ProductModel> products = [];
  List<ServiceModel> services = [];

  @override
  void onInit() {
    getCartProducts();
    super.onInit();
  }

  /// when the user press on purchase now button
  onPurchaseNowPressed() {
    clearCart();
    Get.back();
    CustomSnackBar.showCustomSnackBar(
        title: 'Purchased', message: 'Order placed with success');
  }

  /// get the cart products/services from the product list
  getCartProducts() {
    var productMaps = DummyHelper.products
        .where((p) => (p['quantity'] as int? ?? 0) > 0)
        .toList();
    products = productMaps
        .map((p) => ProductModel(
              id: p['id'],
              name: p['name'],
              quantity: p['quantity'] as int? ?? 0,
              price: p['price'],
              description: p['description'],
            ))
        .toList();

    // Also create service models for cart display
    services = DummyHelper.services.where((service) {
      return productMaps.any((p) => p['id'] == service.id);
    }).map((service) {
      return ServiceModel(
        id: service.id,
        name: service.name,
        description: service.description,
        duration: service.duration,
        price: service.price,
        technicianName: service.technicianName,
        rating: service.rating,
      );
    }).toList();

    update();
  }

  /// clear products in cart and reset cart items count
  clearCart() {
    DummyHelper.products.map((p) => p['quantity'] = 0).toList();
    if (Get.isRegistered<BaseController>()) {
      Get.find<BaseController>().getCartItemsCount();
    }
    update();
  }

  /// increase quantity of a product
  onIncreasePressed(int productId) {
    var product = DummyHelper.products.firstWhere((p) => p['id'] == productId);
    product['quantity'] = (product['quantity'] as int? ?? 0) + 1;
    getCartProducts();
    if (Get.isRegistered<BaseController>()) {
      Get.find<BaseController>().getCartItemsCount();
    }
  }

  /// decrease quantity of a product
  onDecreasePressed(int productId) {
    var product = DummyHelper.products.firstWhere((p) => p['id'] == productId);
    int currentQuantity = product['quantity'] as int? ?? 0;
    if (currentQuantity > 0) {
      product['quantity'] = currentQuantity - 1;
      getCartProducts();
      if (Get.isRegistered<BaseController>()) {
        Get.find<BaseController>().getCartItemsCount();
      }
    }
  }
}
