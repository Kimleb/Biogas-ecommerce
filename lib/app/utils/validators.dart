import 'dart:io';

class Validators {
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    if (price > 999999.99) {
      return 'Price is too high';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    if (quantity < 0) {
      return 'Quantity cannot be negative';
    }
    if (quantity > 999999) {
      return 'Quantity is too high';
    }
    return null;
  }

  static String? validateName(String? value,
      {int minLength = 2, int maxLength = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    if (trimmedValue.length > maxLength) {
      return 'Name must be less than $maxLength characters';
    }

    // Check for valid characters (letters, numbers, spaces, hyphens)
    final validPattern = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    if (!validPattern.hasMatch(trimmedValue)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  static String? validateDescription(String? value, {int maxLength = 1000}) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > maxLength) {
      return 'Description must be less than $maxLength characters';
    }

    return null;
  }

  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Duration is required';
    }

    final trimmedValue = value.trim();
    // Allow formats like "2 hours", "30 minutes", "1h 30m", etc.
    final validPattern = RegExp(
        r'^(\d+\s*(hours?|hrs?|h))?\s*(\d+\s*(minutes?|mins?|m))?\s*$',
        caseSensitive: false);
    if (!validPattern.hasMatch(trimmedValue)) {
      return 'Please enter a valid duration (e.g., "2 hours", "30 minutes")';
    }

    return null;
  }

  static String? validateCategory(
      String? value, List<String> allowedCategories) {
    if (value == null || value.trim().isEmpty) {
      return 'Category is required';
    }

    if (!allowedCategories.contains(value.trim().toLowerCase())) {
      return 'Please select a valid category';
    }

    return null;
  }

  static bool isValidImageFile(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final fileName = file.path.toLowerCase();
    return validExtensions.any((ext) => fileName.endsWith(ext));
  }

  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(
            RegExp(r'[^\w\s\-@.,()&+]'), ''); // Allow only safe characters
  }
}
