import 'package:biogas_technician_app/app/data/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../data/services/database_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/booking_model.dart' as booking;
import '../../../data/models/part_model.dart';
import '../../../data/models/product_model.dart';

// Extension for string capitalization
extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class AdminController extends GetxController {
  late final DatabaseService _databaseService;
  late final CloudinaryService _cloudinaryService;

  final services = <ServiceModel>[].obs;
  final bookings = <booking.BookingModel>[].obs;
  final parts = <PartModel>[].obs;
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs;

  // Form controllers for adding/editing services
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final technicianController = TextEditingController();
  final _selectedCategory = ''.obs;

  // Form controllers for adding/editing parts
  final partNameController = TextEditingController();
  final partDescriptionController = TextEditingController();
  final partPriceController = TextEditingController();
  final partQuantityController = TextEditingController();
  final partBrandController = TextEditingController();
  final partModelController = TextEditingController();

  // Form controllers for adding/editing products
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final productPriceController = TextEditingController();
  final productQuantityController = TextEditingController();

  // Image management
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> uploadedImageUrls = <String>[].obs;
  final RxBool isUploadingImages = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('AdminController: onInit called');
    // Initialize services after onInit
    try {
      _databaseService = Get.find<DatabaseService>();
      _cloudinaryService = Get.find<CloudinaryService>();
      print('AdminController: Services initialized');
      loadData();
    } catch (e) {
      print('AdminController: Error initializing services: $e');
    }
  }

  @override
  void onClose() {
    // Dispose service form controllers
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    durationController.dispose();
    technicianController.dispose();

    // Dispose part form controllers
    partNameController.dispose();
    partDescriptionController.dispose();
    partPriceController.dispose();
    partQuantityController.dispose();
    partBrandController.dispose();
    partModelController.dispose();

    // Dispose product form controllers
    productNameController.dispose();
    productDescriptionController.dispose();
    productPriceController.dispose();
    productQuantityController.dispose();

    super.onClose();
  }

  Future<void> loadData() async {
    try {
      print('AdminController: Starting to load data...');
      isLoading.value = true;

      // Load data concurrently for better performance
      await Future.wait([
        loadServices(),
        loadBookings(),
        loadParts(),
        loadProducts(),
      ]);

      print(
          'AdminController: Data loaded - Services: ${services.length}, Bookings: ${bookings.length}, Parts: ${parts.length}');

      // Temporarily disable real-time listeners to debug
      // _setupRealtimeListeners();
    } catch (e) {
      print('AdminController: Error loading data: $e');
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
      print('AdminController: Load data completed');
    }
  }

  void _setupRealtimeListeners() {
    // Listen for real-time updates
    _databaseService.getServicesStream().listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final serviceList = data.entries
            .map((entry) =>
                ServiceModel.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();
        services.assignAll(serviceList);
      }
    });

    _databaseService.getBookingsStream().listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final bookingList = data.entries
            .map((entry) =>
                BookingModel.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();
        bookings.assignAll(bookingList);
      }
    });

    _databaseService.getPartsStream().listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final partList = data.entries
            .map((entry) =>
                PartModel.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();
        parts.assignAll(partList);
      }
    });
  }

  Future<void> loadServices() async {
    try {
      final serviceList = await _databaseService.getAllServices();
      services.assignAll(serviceList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load services: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> loadBookings() async {
    try {
      final bookingList = await _databaseService.getAllBookings();
      bookings.assignAll(bookingList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bookings: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> loadParts() async {
    try {
      final partList = await _databaseService.getAllParts();
      parts.assignAll(partList.map((data) => PartModel.fromJson(data)));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load parts: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> loadProducts() async {
    try {
      // For now, return empty list as products are not implemented in DatabaseService
      products.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Image management methods
  Future<void> pickImages() async {
    try {
      final pickedFiles =
          await _cloudinaryService.showImagePickerOptions(Get.context!);
      if (pickedFiles != null) {
        selectedImages.add(pickedFiles);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void removeImage(int index) {
    if (index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void clearSelectedImages() {
    selectedImages.clear();
    uploadedImageUrls.clear();
  }

  Future<bool> uploadSelectedImages({String folder = 'admin_uploads'}) async {
    try {
      isUploadingImages.value = true;

      if (selectedImages.isEmpty) {
        Get.snackbar('Warning', 'No images selected');
        return false;
      }

      final uploadedUrls = await _cloudinaryService.uploadMultipleImages(
        selectedImages,
        folder: folder,
      );

      if (uploadedUrls.isNotEmpty) {
        uploadedImageUrls.assignAll(uploadedUrls);
        Get.snackbar(
            'Success', '${uploadedUrls.length} images uploaded successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to upload images');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload images: $e');
      return false;
    } finally {
      isUploadingImages.value = false;
    }
  }

  // Service management methods
  void addService() async {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        _selectedCategory.value.isEmpty) {
      Get.snackbar(
          'Error', 'Please fill all required fields including category',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      // Upload images if any selected
      if (selectedImages.isNotEmpty) {
        final success = await uploadSelectedImages(folder: 'service_images');
        if (!success) return;
      }

      final service = ServiceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        description: descriptionController.text,
        images: uploadedImageUrls.isEmpty ? [''] : uploadedImageUrls,
        thumbnailImages: uploadedImageUrls
            .map((url) => _cloudinaryService.getThumbnailUrl(url,
                width: 200, height: 200))
            .toList(),
        duration: durationController.text,
        price: double.tryParse(priceController.text) ?? 0.0,
        technicianName: technicianController.text,
        category: _selectedCategory.value,
        categoryId: _selectedCategory.value,
        createdAt: DateTime.now(),
      );

      await _databaseService.addService(service);
      clearServiceForm();
      Get.back();
      Get.snackbar('Success', 'Service added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add service: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  void updateService(ServiceModel service) {
    final index = services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      services[index] = service;
      _databaseService.updateService(service);
      Get.snackbar('Success', 'Service updated successfully');
    }
  }

  void deleteService(String id) {
    services.removeWhere((s) => s.id == id);
    _databaseService.deleteService(id);
    Get.snackbar('Success', 'Service deleted successfully');
  }

  void clearServiceForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    durationController.clear();
    technicianController.clear();
    _selectedCategory.value = '';
    clearSelectedImages();
  }

  // Part management methods
  void addPart() async {
    if (partNameController.text.isEmpty ||
        partDescriptionController.text.isEmpty ||
        partPriceController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    // Upload images if any selected
    if (selectedImages.isNotEmpty) {
      final success = await uploadSelectedImages(folder: 'part_images');
      if (!success) return;
    }

    final part = PartModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: partNameController.text,
      description: partDescriptionController.text,
      images: uploadedImageUrls.isEmpty ? [''] : uploadedImageUrls,
      thumbnailImages: uploadedImageUrls
          .map((url) =>
              _cloudinaryService.getThumbnailUrl(url, width: 200, height: 200))
          .toList(),
      price: double.tryParse(partPriceController.text) ?? 0.0,
      quantity: int.tryParse(partQuantityController.text) ?? 0,
      brand: partBrandController.text.isEmpty ? null : partBrandController.text,
      model: partModelController.text.isEmpty ? null : partModelController.text,
      createdAt: DateTime.now(),
    );

    parts.add(part);
    _databaseService.addPart(part.toJson());
    clearPartForm();
    Get.snackbar('Success', 'Part added successfully');
  }

  void updatePart(PartModel part) {
    final index = parts.indexWhere((p) => p.id == part.id);
    if (index != -1) {
      parts[index] = part;
      _databaseService.updatePart(part.id, part.toJson());
      Get.snackbar('Success', 'Part updated successfully');
    }
  }

  void deletePart(String id) {
    parts.removeWhere((p) => p.id == id);
    _databaseService.deletePart(id);
    Get.snackbar('Success', 'Part deleted successfully');
  }

  void clearPartForm() {
    partNameController.clear();
    partDescriptionController.clear();
    partPriceController.clear();
    partQuantityController.clear();
    partBrandController.clear();
    partModelController.clear();
    clearSelectedImages();
  }

  // Product management methods
  void addProduct() async {
    if (productNameController.text.isEmpty ||
        productDescriptionController.text.isEmpty ||
        productPriceController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    // Upload images if any selected
    if (selectedImages.isNotEmpty) {
      final success = await uploadSelectedImages(folder: 'product_images');
      if (!success) return;
    }

    final product = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: productNameController.text,
      description: productDescriptionController.text,
      images: uploadedImageUrls.isEmpty ? [''] : uploadedImageUrls,
      thumbnailImages: uploadedImageUrls
          .map((url) =>
              _cloudinaryService.getThumbnailUrl(url, width: 200, height: 200))
          .toList(),
      price: double.tryParse(productPriceController.text) ?? 0.0,
      quantity: int.tryParse(productQuantityController.text) ?? 0,
      createdAt: DateTime.now(),
    );

    products.add(product);
    // _databaseService.addProduct(product); // Not implemented yet
    clearProductForm();
    Get.snackbar('Success', 'Product added successfully');
  }

  void updateProduct(ProductModel product) {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      // _databaseService.updateProduct(product); // Not implemented yet
      Get.snackbar('Success', 'Product updated successfully');
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    // _databaseService.deleteProduct(id); // Not implemented yet
    Get.snackbar('Success', 'Product deleted successfully');
  }

  void clearProductForm() {
    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    productQuantityController.clear();
    clearSelectedImages();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    // Clear forms when switching tabs
    clearServiceForm();
    clearPartForm();
    clearProductForm();
  }

  // Get status color for bookings
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Booking management methods
  Future<void> updateBookingStatus(
      booking.BookingModel booking, String newStatus) async {
    try {
      // Create updated booking with new status
      final updatedBooking = BookingModel(
        id: booking.id,
        customerId: booking.customerId,
        customerName: booking.customerName,
        serviceId: booking.serviceId,
        serviceName: booking.serviceName,
        technicianId: booking.technicianId,
        technicianName: booking.technicianName,
        bookingDate: booking.bookingDate,
        serviceDate: booking.serviceDate,
        status: newStatus,
        totalPrice: booking.totalPrice,
        address: booking.address,
        notes: booking.notes,
        selectedParts: booking.selectedParts,
        rating: booking.rating,
        review: booking.review,
      );

      // Update in database
      await _databaseService.updateBooking(updatedBooking);

      // Update local list
      final index = bookings.indexWhere((b) => b.id == booking.id);
      if (index != -1) {
        bookings[index] = updatedBooking;
      }

      Get.snackbar('Success', 'Booking status updated to $newStatus');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update booking status: $e');
    }
  }

  void deleteBooking(String id) {
    bookings.removeWhere((b) => b.id == id);
    _databaseService.deleteBooking(id);
    Get.snackbar('Success', 'Booking deleted successfully');
  }

  // Dialog methods
  void showAddServiceDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.85),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Service',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.back();
                        clearServiceForm();
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                16.verticalSpace,

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Service Name
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Service Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.eco_rounded),
                          ),
                        ),
                        16.verticalSpace,

                        // Description
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        16.verticalSpace,

                        // Price and Duration Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: priceController,
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            16.horizontalSpace,
                            Expanded(
                              child: TextField(
                                controller: durationController,
                                decoration: InputDecoration(
                                  labelText: 'Duration',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                              ),
                            ),
                          ],
                        ),
                        16.verticalSpace,

                        // Technician Name
                        TextField(
                          controller: technicianController,
                          decoration: InputDecoration(
                            labelText: 'Technician Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        16.verticalSpace,

                        // Category Selection
                        Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              value: _selectedCategory.value.isEmpty
                                  ? null
                                  : _selectedCategory.value,
                              items: [
                                'installation',
                                'maintenance',
                                'inspection',
                                'consultation',
                                'emergency',
                                'training'
                              ].map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category[0].toUpperCase() +
                                      category.substring(1)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                _selectedCategory.value = value ?? '';
                              },
                            )),
                        16.verticalSpace,

                        // Image Upload Section
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Service Images',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Obx(() => Text(
                                        '${selectedImages.length} selected',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12.sp,
                                        ),
                                      )),
                                ],
                              ),
                              8.verticalSpace,

                              // Image Preview Grid
                              Obx(() {
                                if (selectedImages.isEmpty) {
                                  return Container(
                                    height: 120.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          style: BorderStyle.solid),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_outlined,
                                              size: 40.w,
                                              color: Colors.grey.shade400),
                                          8.verticalSpace,
                                          Text(
                                            'No images selected',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  height: 120.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: selectedImages.length,
                                    itemBuilder: (context, index) {
                                      final file = selectedImages[index];
                                      return Container(
                                        width: 100.w,
                                        margin: EdgeInsets.only(right: 8.w),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 100.w,
                                              height: 120.h,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                child: Image.file(
                                                  file,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors
                                                              .grey.shade400),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () => selectedImages
                                                    .removeAt(index),
                                                child: Container(
                                                  width: 24.w,
                                                  height: 24.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16.w,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),

                              8.verticalSpace,

                              // Upload Button
                              Obx(() => isUploadingImages.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                            strokeWidth: 2),
                                        8.horizontalSpace,
                                        Text('Uploading...'),
                                      ],
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: pickImages,
                                      icon: Icon(Icons.cloud_upload_outlined),
                                      label: Text('Choose Images'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            Size(double.infinity, 40.h),
                                      ),
                                    )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                16.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          clearServiceForm();
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: isUploadingImages.value
                                ? null
                                : () {
                                    addService();
                                    Get.back();
                                  },
                            child: isUploadingImages.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16.w,
                                        height: 16.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      8.horizontalSpace,
                                      Text('Adding...'),
                                    ],
                                  )
                                : Text('Add Service'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40.h),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
