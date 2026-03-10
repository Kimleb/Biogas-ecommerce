import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/booking_model.dart' as booking;
import '../../../data/models/part_model.dart';
import '../../../data/models/product_model.dart';
import '../../../utils/logger.dart';
import '../../../utils/validators.dart';
import '../../../config/production_config.dart';

// Global navigator key for context access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  // Stream subscriptions for proper cleanup
  StreamSubscription? _servicesSubscription;
  StreamSubscription? _bookingsSubscription;
  StreamSubscription? _partsSubscription;
  StreamSubscription? _productsSubscription;

  // Flag to prevent multiple listener setups
  bool _isSettingUpListeners = false;

  // Timer for debouncing listener setup calls
  Timer? _debounceTimer;

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
    AppLogger.info('AdminController initialized', 'AdminController');
    // Initialize services after onInit
    try {
      _databaseService = Get.find<DatabaseService>();
      _cloudinaryService = Get.find<CloudinaryService>();
      AppLogger.info('Services initialized successfully', 'AdminController');
      loadData();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error initializing services', e, stackTrace, 'AdminController');
    }
  }

  @override
  void onClose() {
    // Cancel stream subscriptions to prevent memory leaks
    _cancelRealtimeListeners();

    AppLogger.info('AdminController disposed - subscriptions cancelled',
        'AdminController');

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
      AppLogger.info('Starting to load data...', 'AdminController');
      isLoading.value = true;

      // Load data concurrently for better performance
      final results = await Future.wait([
        loadServices(),
        loadBookings(),
        loadParts(),
        loadProducts(),
      ], eagerError: false);

      AppLogger.info(
          'Data loaded - Services: ${services.length}, Bookings: ${bookings.length}, Parts: ${parts.length}',
          'AdminController');

      // Setup real-time listeners after initial load
      _setupRealtimeListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error loading data', e, stackTrace, 'AdminController');
      Get.snackbar(
        'Loading Error',
        'Failed to load some data. Please check your connection.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning_amber_rounded),
      );
    } finally {
      isLoading.value = false;
      AppLogger.info('Load data completed', 'AdminController');
    }
  }

  void _setupRealtimeListeners() {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    // Debounce the listener setup to prevent rapid successive calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_isSettingUpListeners) {
        AppLogger.warning('Listeners are already being set up, skipping...',
            'AdminController');
        return;
      }

      try {
        _isSettingUpListeners = true;
        AppLogger.info('Setting up real-time listeners...', 'AdminController');

        // Cancel existing subscriptions before creating new ones
        _cancelRealtimeListeners();

        // Add a small delay to ensure proper cleanup
        Future.delayed(const Duration(milliseconds: 100), () {
          _createListeners();
          _isSettingUpListeners = false;
        });
      } catch (e, stackTrace) {
        _isSettingUpListeners = false;
        AppLogger.error('Error setting up real-time listeners', e, stackTrace,
            'AdminController');
      }
    });
  }

  void _cancelRealtimeListeners() {
    try {
      // Cancel debounce timer
      _debounceTimer?.cancel();
      _debounceTimer = null;

      _servicesSubscription?.cancel();
      _bookingsSubscription?.cancel();
      _partsSubscription?.cancel();

      _servicesSubscription = null;
      _bookingsSubscription = null;
      _partsSubscription = null;
      _isSettingUpListeners = false;

      AppLogger.info('Real-time listeners cancelled', 'AdminController');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error cancelling listeners', e, stackTrace, 'AdminController');
    }
  }

  void _createListeners() {
    try {
      // Check if listeners are already active
      if (_servicesSubscription != null ||
          _bookingsSubscription != null ||
          _partsSubscription != null) {
        AppLogger.warning(
            'Listeners already active, skipping setup', 'AdminController');
        return;
      }

      // Listen for real-time updates for services
      _servicesSubscription =
          _databaseService.getServicesStream().listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final serviceList = <ServiceModel>[];

          for (final entry in data.entries) {
            try {
              // Convert dynamic map to string-keyed map safely
              final serviceData = <String, dynamic>{};
              if (entry.value is Map) {
                (entry.value as Map).forEach((key, value) {
                  serviceData[key.toString()] = value;
                });
              }

              final service = ServiceModel.fromJson(serviceData);
              serviceList.add(service);
            } catch (e, stackTrace) {
              AppLogger.error('Error parsing service ${entry.key}', e,
                  stackTrace, 'AdminController');
            }
          }

          services.assignAll(serviceList);
          AppLogger.info('Real-time update - Services: ${services.length}',
              'AdminController');
        }
      }, onError: (error) {
        AppLogger.error('Real-time listener error for services', error, null,
            'AdminController');
      });

      // Listen for real-time updates for bookings
      _bookingsSubscription =
          _databaseService.getBookingsStream().listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final bookingList = <booking.BookingModel>[];

          for (final entry in data.entries) {
            try {
              // Convert dynamic map to string-keyed map safely
              final bookingData = <String, dynamic>{};
              if (entry.value is Map) {
                (entry.value as Map).forEach((key, value) {
                  bookingData[key.toString()] = value;
                });
              }

              final bookingItem = booking.BookingModel.fromJson(bookingData);
              bookingList.add(bookingItem);
            } catch (e, stackTrace) {
              AppLogger.error('Error parsing booking ${entry.key}', e,
                  stackTrace, 'AdminController');
            }
          }

          bookings.assignAll(bookingList);
          AppLogger.info('Real-time update - Bookings: ${bookings.length}',
              'AdminController');
        }
      }, onError: (error) {
        AppLogger.error('Real-time listener error for bookings', error, null,
            'AdminController');
      });

      // Listen for real-time updates for parts
      _partsSubscription = _databaseService.getPartsStream().listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final partsList = <PartModel>[];

          for (final entry in data.entries) {
            try {
              // Convert dynamic map to string-keyed map safely
              final partData = <String, dynamic>{};
              if (entry.value is Map) {
                (entry.value as Map).forEach((key, value) {
                  partData[key.toString()] = value;
                });
              }

              final part = PartModel.fromJson(partData);
              partsList.add(part);
            } catch (e, stackTrace) {
              AppLogger.error('Error parsing part ${entry.key}', e, stackTrace,
                  'AdminController');
            }
          }

          parts.assignAll(partsList);
          AppLogger.info(
              'Real-time update - Parts: ${parts.length}', 'AdminController');
        }
      }, onError: (error) {
        AppLogger.error('Real-time listener error for parts', error, null,
            'AdminController');
      });

      AppLogger.info('Real-time listeners setup completed', 'AdminController');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error creating listeners', e, stackTrace, 'AdminController');
    }
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
      AppLogger.info('Starting image selection process', 'AdminController');

      // Use Get.context with null safety
      final context = Get.context;
      if (context == null) {
        AppLogger.warning('Get.context is null when trying to pick images',
            'AdminController');
        Get.snackbar(
            'Error', 'Unable to open image picker - context not available');
        return;
      }

      AppLogger.info('Context available, calling showImagePickerOptions',
          'AdminController');
      final pickedFiles =
          await _cloudinaryService.showImagePickerOptions(context);

      if (pickedFiles != null) {
        // Validate image file
        if (!Validators.isValidImageFile(pickedFiles)) {
          Get.snackbar('Error', 'Invalid image file format');
          return;
        }

        AppLogger.info('Image selected successfully: ${pickedFiles.path}',
            'AdminController');
        selectedImages.add(pickedFiles);
        Get.snackbar('Success', 'Image selected successfully');
      } else {
        AppLogger.info('No image selected', 'AdminController');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in pickImages', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  // Context-aware version for use in dialogs
  Future<void> pickImagesWithContext(BuildContext context) async {
    try {
      AppLogger.info(
          'pickImagesWithContext called with valid context', 'AdminController');

      final pickedFiles =
          await _cloudinaryService.showImagePickerOptions(context);

      if (pickedFiles != null) {
        // Validate image file
        if (!Validators.isValidImageFile(pickedFiles)) {
          Get.snackbar('Error', 'Invalid image file format');
          return;
        }

        AppLogger.info('Image selected successfully: ${pickedFiles.path}',
            'AdminController');
        selectedImages.add(pickedFiles);
        Get.snackbar('Success', 'Image selected successfully');
      } else {
        AppLogger.info('No image selected', 'AdminController');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error in pickImagesWithContext', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
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

      // Validate image count
      if (selectedImages.length > ProductionConfig.maxImagesPerItem) {
        Get.snackbar('Error',
            'Maximum ${ProductionConfig.maxImagesPerItem} images allowed');
        return false;
      }

      // Validate file sizes
      for (final file in selectedImages) {
        if (file.lengthSync() > ProductionConfig.maxImageSize) {
          Get.snackbar('Error',
              'Image size exceeds ${ProductionConfig.maxImageSize ~/ (1024 * 1024)}MB limit');
          return false;
        }
      }

      final uploadedUrls = await _cloudinaryService.uploadMultipleImages(
        selectedImages,
        folder: folder,
      );

      if (uploadedUrls.isNotEmpty) {
        uploadedImageUrls.assignAll(uploadedUrls);
        Get.snackbar(
            'Success', '${uploadedUrls.length} images uploaded successfully');
        AppLogger.info(
            'Successfully uploaded ${uploadedUrls.length} images to $folder',
            'AdminController');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to upload images');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to upload images', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to upload images: $e');
      return false;
    } finally {
      isUploadingImages.value = false;
    }
  }

  // Service management methods
  void addService() async {
    // Validate inputs
    final nameError = Validators.validateName(nameController.text);
    final descriptionError =
        Validators.validateDescription(descriptionController.text);
    final priceError = Validators.validatePrice(priceController.text);
    final durationError = Validators.validateDuration(durationController.text);

    if (nameError != null ||
        descriptionError != null ||
        priceError != null ||
        durationError != null ||
        _selectedCategory.value.isEmpty) {
      Get.snackbar(
          'Validation Error',
          nameError ??
              descriptionError ??
              priceError ??
              durationError ??
              'Please select a category',
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
        name: Validators.sanitizeInput(nameController.text),
        description: Validators.sanitizeInput(descriptionController.text),
        images: uploadedImageUrls.isEmpty ? [''] : uploadedImageUrls,
        thumbnailImages: uploadedImageUrls
            .map((url) => _cloudinaryService.getThumbnailUrl(url,
                width: 200, height: 200))
            .toList(),
        duration: Validators.sanitizeInput(durationController.text),
        price: double.tryParse(priceController.text) ?? 0.0,
        technicianName: Validators.sanitizeInput(technicianController.text),
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
      AppLogger.info(
          'Service added successfully: ${service.name}', 'AdminController');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to add service', e, stackTrace, 'AdminController');
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
    // Validate inputs
    final nameError = Validators.validateName(partNameController.text);
    final descriptionError =
        Validators.validateDescription(partDescriptionController.text);
    final priceError = Validators.validatePrice(partPriceController.text);
    final quantityError =
        Validators.validateQuantity(partQuantityController.text);

    if (nameError != null ||
        descriptionError != null ||
        priceError != null ||
        quantityError != null) {
      Get.snackbar(
          'Validation Error',
          nameError ??
              descriptionError ??
              priceError ??
              quantityError ??
              'Validation failed',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    // Upload images if any selected
    if (selectedImages.isNotEmpty) {
      final success = await uploadSelectedImages(folder: 'part_images');
      if (!success) return;
    }

    try {
      final part = PartModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: Validators.sanitizeInput(partNameController.text),
        description: Validators.sanitizeInput(partDescriptionController.text),
        images: uploadedImageUrls.isEmpty ? [''] : uploadedImageUrls,
        thumbnailImages: uploadedImageUrls
            .map((url) => _cloudinaryService.getThumbnailUrl(url,
                width: 200, height: 200))
            .toList(),
        price: double.tryParse(partPriceController.text) ?? 0.0,
        quantity: int.tryParse(partQuantityController.text) ?? 0,
        brand: partBrandController.text.trim().isEmpty
            ? null
            : Validators.sanitizeInput(partBrandController.text),
        model: partModelController.text.trim().isEmpty
            ? null
            : Validators.sanitizeInput(partModelController.text),
        createdAt: DateTime.now(),
      );

      parts.add(part);
      await _databaseService.addPart(part.toJson());
      clearPartForm();
      Get.snackbar('Success', 'Part added successfully');
      AppLogger.info(
          'Part added successfully: ${part.name}', 'AdminController');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add part', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to add part: $e');
    }
  }

  void updatePart(PartModel part) {
    try {
      final index = parts.indexWhere((p) => p.id == part.id);
      if (index != -1) {
        parts[index] = part;
        _databaseService.updatePart(part.id, part.toJson());
        Get.snackbar('Success', 'Part updated successfully');
        AppLogger.info(
            'Part updated successfully: ${part.name}', 'AdminController');
      } else {
        Get.snackbar('Error', 'Part not found');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to update part', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to update part: $e');
    }
  }

  void deletePart(String id) {
    try {
      final part = parts.firstWhereOrNull((p) => p.id == id);
      if (part != null) {
        parts.removeWhere((p) => p.id == id);
        _databaseService.deletePart(id);
        Get.snackbar('Success', 'Part deleted successfully');
        AppLogger.info(
            'Part deleted successfully: ${part.name}', 'AdminController');
      } else {
        Get.snackbar('Error', 'Part not found');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to delete part', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to delete part: $e');
    }
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
    // Validate inputs
    final nameError = Validators.validateName(productNameController.text);
    final descriptionError =
        Validators.validateDescription(productDescriptionController.text);
    final priceError = Validators.validatePrice(productPriceController.text);
    final quantityError =
        Validators.validateQuantity(productQuantityController.text);

    if (nameError != null ||
        descriptionError != null ||
        priceError != null ||
        quantityError != null) {
      Get.snackbar(
          'Validation Error',
          nameError ??
              descriptionError ??
              priceError ??
              quantityError ??
              'Validation failed',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    // Upload images if any selected
    if (selectedImages.isNotEmpty) {
      final success = await uploadSelectedImages(folder: 'product_images');
      if (!success) return;
    }

    try {
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: Validators.sanitizeInput(productNameController.text),
        description:
            Validators.sanitizeInput(productDescriptionController.text),
        images: uploadedImageUrls.isEmpty ? [''] : uploadedImageUrls,
        thumbnailImages: uploadedImageUrls
            .map((url) => _cloudinaryService.getThumbnailUrl(url,
                width: 200, height: 200))
            .toList(),
        price: double.tryParse(productPriceController.text) ?? 0.0,
        quantity: int.tryParse(productQuantityController.text) ?? 0,
        createdAt: DateTime.now(),
      );

      products.add(product);
      // _databaseService.addProduct(product); // Not implemented yet
      clearProductForm();
      Get.snackbar('Success', 'Product added successfully');
      AppLogger.info(
          'Product added successfully: ${product.name}', 'AdminController');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to add product', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to add product: $e');
    }
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
      booking.BookingModel bookingModel, String newStatus) async {
    try {
      // Validate status
      final validStatuses = [
        'pending',
        'confirmed',
        'in_progress',
        'completed',
        'cancelled'
      ];
      if (!validStatuses.contains(newStatus.toLowerCase())) {
        Get.snackbar('Error', 'Invalid booking status');
        return;
      }

      // Create updated booking with new status
      final updatedBooking = booking.BookingModel(
        id: bookingModel.id,
        customerId: bookingModel.customerId,
        customerName: bookingModel.customerName,
        serviceId: bookingModel.serviceId,
        serviceName: bookingModel.serviceName,
        technicianId: bookingModel.technicianId,
        technicianName: bookingModel.technicianName,
        bookingDate: bookingModel.bookingDate,
        serviceDate: bookingModel.serviceDate,
        status: newStatus,
        totalPrice: bookingModel.totalPrice,
        address: bookingModel.address,
        notes: bookingModel.notes,
        selectedParts: bookingModel.selectedParts,
        rating: bookingModel.rating,
        review: bookingModel.review,
      );

      // Update in database
      await _databaseService.updateBooking(updatedBooking);

      // Update local list
      final index = bookings.indexWhere((b) => b.id == bookingModel.id);
      if (index != -1) {
        bookings[index] = updatedBooking;
      }

      Get.snackbar('Success', 'Booking status updated to $newStatus');
      AppLogger.info('Booking status updated: ${bookingModel.id} -> $newStatus',
          'AdminController');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to update booking status', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to update booking status: $e');
    }
  }

  void deleteBooking(String id) {
    try {
      final booking = bookings.firstWhereOrNull((b) => b.id == id);
      if (booking != null) {
        bookings.removeWhere((b) => b.id == id);
        _databaseService.deleteBooking(id);
        Get.snackbar('Success', 'Booking deleted successfully');
        AppLogger.info(
            'Booking deleted successfully: ${booking.id}', 'AdminController');
      } else {
        Get.snackbar('Error', 'Booking not found');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to delete booking', e, stackTrace, 'AdminController');
      Get.snackbar('Error', 'Failed to delete booking: $e');
    }
  }

  // Dialog methods
  void showAddServiceDialog() {
    Get.dialog(
      Dialog(
        child: Builder(
          builder: (context) => Container(
            width: Get.width * 0.9,
            constraints: BoxConstraints(maxHeight: Get.height * 0.85),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: _buildAddServiceDialogContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddServiceDialogContent(BuildContext context) {
    return Column(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 40.w, color: Colors.grey.shade400),
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
                                            color: Colors.grey.shade300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade200,
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.grey.shade400),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () =>
                                            selectedImages.removeAt(index),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(strokeWidth: 2),
                                8.horizontalSpace,
                                Text('Uploading...'),
                              ],
                            )
                          : ElevatedButton.icon(
                              onPressed: () => pickImagesWithContext(context),
                              icon: Icon(Icons.cloud_upload_outlined),
                              label: Text('Choose Images'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 40.h),
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
                    onPressed: isUploadingImages.value ? null : addService,
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
    );
  }

  void showAddPartDialog() {
    Get.dialog(
      Dialog(
        child: Builder(
          builder: (context) => Container(
            width: Get.width * 0.9,
            constraints: BoxConstraints(maxHeight: Get.height * 0.85),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: _buildAddPartDialogContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPartDialogContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add New Part',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
            ),
            IconButton(
              onPressed: () {
                Get.back();
                clearPartForm();
              },
              icon: Icon(Icons.close, color: Colors.grey[600]),
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
                // Part Name
                TextField(
                  controller: partNameController,
                  decoration: InputDecoration(
                    labelText: 'Part Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3192)),
                    ),
                    prefixIcon: Icon(Icons.build, color: Color(0xFF2E3192)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2E3192), width: 2),
                    ),
                  ),
                ),
                16.verticalSpace,

                // Description
                TextField(
                  controller: partDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3192)),
                    ),
                    prefixIcon:
                        Icon(Icons.description, color: Color(0xFF2E3192)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2E3192), width: 2),
                    ),
                  ),
                  maxLines: 3,
                ),
                16.verticalSpace,

                // Price and Quantity Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: partPriceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2E3192)),
                          ),
                          prefixIcon: Icon(Icons.attach_money,
                              color: Color(0xFF2E3192)),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF2E3192), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: TextField(
                        controller: partQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2E3192)),
                          ),
                          prefixIcon:
                              Icon(Icons.inventory, color: Color(0xFF2E3192)),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF2E3192), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,

                // Brand
                TextField(
                  controller: partBrandController,
                  decoration: InputDecoration(
                    labelText: 'Brand (Optional)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3192)),
                    ),
                    prefixIcon: Icon(Icons.branding_watermark,
                        color: Color(0xFF2E3192)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2E3192), width: 2),
                    ),
                  ),
                ),
                16.verticalSpace,

                // Model
                TextField(
                  controller: partModelController,
                  decoration: InputDecoration(
                    labelText: 'Model (Optional)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3192)),
                    ),
                    prefixIcon:
                        Icon(Icons.model_training, color: Color(0xFF2E3192)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2E3192), width: 2),
                    ),
                  ),
                ),
                16.verticalSpace,

                // Image Upload Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Color(0xFF2E3192).withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Color(0xFF2E3192).withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Images',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3192),
                        ),
                      ),
                      8.verticalSpace,

                      // Selected Images Preview
                      Obx(() => Wrap(
                            spacing: 8.w,
                            runSpacing: 8.w,
                            children:
                                selectedImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final image = entry.value;
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(
                                      image,
                                      width: 80.w,
                                      height: 80.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          selectedImages.removeAt(index),
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
                              );
                            }).toList(),
                          )),

                      8.verticalSpace,

                      // Upload Button
                      Obx(() => isUploadingImages.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF2E3192)),
                                ),
                                8.horizontalSpace,
                                Text('Uploading...'),
                              ],
                            )
                          : ElevatedButton.icon(
                              onPressed: () => pickImagesWithContext(context),
                              icon: Icon(Icons.cloud_upload_outlined),
                              label: Text('Choose Images'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2E3192),
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 40.h),
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
                  clearPartForm();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF2E3192)),
                  foregroundColor: Color(0xFF2E3192),
                ),
                child: Text('Cancel'),
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: Obx(() => ElevatedButton(
                    onPressed: isUploadingImages.value ? null : addPart,
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
                        : Text('Add Part'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF8C00),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 40.h),
                    ),
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
