import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/services/database_service.dart';
import '../../base/controllers/base_controller.dart';

class CartController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // to hold the services in cart
  List<ProductModel> products = [];
  List<ServiceModel> services = [];

  // Cart items stored as quantities (in a real app, this would be in Firebase)
  RxMap<String, int> cartQuantities = <String, int>{}.obs;
  RxMap<String, int> serviceQuantities = <String, int>{}.obs;

  @override
  void onInit() {
    getCartProducts();
    super.onInit();
  }

  /// when the user press on purchase now button
  onPurchaseNowPressed() {
    if (products.isEmpty && services.isEmpty) {
      Get.snackbar('Cart Empty', 'Add items to cart first',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    clearCart();
    Get.back();
    CustomSnackBar.showCustomSnackBar(
        title: 'Purchased', message: 'Order placed with success');
  }

  /// get the cart products/services from Firebase
  Future<void> getCartProducts() async {
    try {
      // Get services from Firebase
      final allServices = await _databaseService.getAllServices();

      // Filter services that are in cart
      services = allServices.where((service) {
        return (serviceQuantities[service.id] ?? 0) > 0;
      }).toList();

      update();
    } catch (e) {
      print('Error loading cart products: $e');
      Get.snackbar('Error', 'Failed to load cart items',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  /// clear products in cart and reset cart items count
  clearCart() {
    cartQuantities.clear();
    serviceQuantities.clear();
    products.clear();
    services.clear();

    if (Get.isRegistered<BaseController>()) {
      Get.find<BaseController>().getCartItemsCount();
    }
    update();
  }

  /// increase quantity of a service
  onIncreasePressed(String serviceId) {
    serviceQuantities[serviceId] = (serviceQuantities[serviceId] ?? 0) + 1;
    getCartProducts();
    if (Get.isRegistered<BaseController>()) {
      Get.find<BaseController>().getCartItemsCount();
    }
  }

  /// decrease quantity of a service
  onDecreasePressed(String serviceId) {
    int currentQuantity = serviceQuantities[serviceId] ?? 0;
    if (currentQuantity > 0) {
      serviceQuantities[serviceId] = currentQuantity - 1;
      if (serviceQuantities[serviceId] == 0) {
        serviceQuantities.remove(serviceId);
      }
      getCartProducts();
      if (Get.isRegistered<BaseController>()) {
        Get.find<BaseController>().getCartItemsCount();
      }
    }
  }

  /// Get total items in cart
  int get totalItems {
    return cartQuantities.values.fold(0, (sum, qty) => sum + qty) +
        serviceQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  /// Get total price
  double get totalPrice {
    double serviceTotal = services.fold(0.0, (sum, service) {
      return sum + (service.price * (serviceQuantities[service.id] ?? 0));
    });

    double productTotal = products.fold(0.0, (sum, product) {
      return sum + (product.price * (cartQuantities[product.id] ?? 0));
    });

    return serviceTotal + productTotal;
  }
}
