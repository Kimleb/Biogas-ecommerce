import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../config/cloudinary_config.dart';

// Extension for spacing
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class CloudinaryService extends GetxService {
  static CloudinaryService get to => Get.find();

  final ImagePicker _imagePicker = ImagePicker();

  // Cloudinary configuration
  // NOTE: Do NOT store secrets (apiSecret) in a client app.
  // Use unsigned uploads with an upload preset, or proxy uploads through your backend.
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '',
  );

  String _runtimeCloudName = '';
  String _runtimeUploadPreset = '';

  String get effectiveCloudName =>
      _runtimeCloudName.isNotEmpty ? _runtimeCloudName : cloudName;
  String get effectiveUploadPreset =>
      _runtimeUploadPreset.isNotEmpty ? _runtimeUploadPreset : uploadPreset;

  bool get isConfigured => CloudinaryConfig.isValidConfig;

  void configure({required String cloudName, required String uploadPreset}) {
    _runtimeCloudName = cloudName.trim();
    _runtimeUploadPreset = uploadPreset.trim();
    print(
        'Cloudinary configured: cloudName=$cloudName, uploadPreset=$uploadPreset');
  }

  @override
  void onInit() {
    super.onInit();
    print('Cloudinary service initialized');
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Upload image to Cloudinary using HTTP request
  Future<String?> uploadImage(File imageFile,
      {String folder = 'biogas_app'}) async {
    try {
      if (!isConfigured) {
        Get.snackbar(
          'Configuration Error',
          'Cloudinary is not configured. Please set your cloud name and upload preset.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        print(
            'Cloudinary not configured: cloudName=$effectiveCloudName, uploadPreset=$effectiveUploadPreset');
        return null;
      }

      print(
          'Starting upload to Cloudinary: cloudName=$effectiveCloudName, folder=$folder');

      Get.snackbar(
        'Uploading',
        'Please wait while we upload your image...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/$effectiveCloudName/image/upload'),
      );

      // Add file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      // Add form fields
      request.fields['upload_preset'] = effectiveUploadPreset;
      request.fields['folder'] = folder;

      print('Upload request prepared, sending...');

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: $responseBody');

      final decoded = jsonDecode(responseBody);
      if (response.statusCode == 200 && decoded is Map) {
        final secureUrl = decoded['secure_url'];
        if (secureUrl is String && secureUrl.isNotEmpty) {
          Get.snackbar(
            'Success',
            'Image uploaded successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          print('Upload successful: $secureUrl');
          return secureUrl;
        }
        throw Exception('Upload succeeded but secure_url is missing');
      }

      // Handle specific error cases
      String errorMessage = 'Upload failed (${response.statusCode})';

      if (response.statusCode == 400) {
        if (responseBody.contains('upload preset')) {
          errorMessage =
              'Upload preset "$effectiveUploadPreset" not found or invalid. Please check your Cloudinary settings.';
        } else if (responseBody.contains('cloud name')) {
          errorMessage =
              'Cloud name "$effectiveCloudName" is invalid. Please check your Cloudinary cloud name.';
        } else if (responseBody.contains('file')) {
          errorMessage =
              'Invalid file format or file too large. Please try a different image.';
        } else {
          errorMessage =
              'Bad request (400). Please check your Cloudinary configuration.';
        }
      } else if (response.statusCode == 401) {
        errorMessage =
            'Authentication failed. Check your Cloudinary API settings.';
      } else if (response.statusCode == 403) {
        errorMessage =
            'Access denied. Upload preset may not allow unsigned uploads.';
      } else if (response.statusCode == 404) {
        errorMessage = 'Cloud name "$effectiveCloudName" not found.';
      }

      final error = decoded is Map
          ? (decoded['error']?['message'] ?? decoded['error'])
          : null;

      if (error != null) {
        errorMessage += '\nDetails: $error';
      }

      print('Upload error: $errorMessage');

      Get.snackbar(
        'Upload Failed',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      throw Exception(errorMessage);
    } catch (e) {
      print('Upload exception: $e');
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles,
      {String folder = 'biogas_app'}) async {
    List<String> uploadedUrls = [];

    for (File imageFile in imageFiles) {
      final url = await uploadImage(imageFile, folder: folder);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // Get optimized image URL (basic transformation)
  String getOptimizedImageUrl(String publicId,
      {int width = 800, int height = 600}) {
    return 'https://res.cloudinary.com/$effectiveCloudName/image/fetch/w_$width,h_$height,q_auto,f_auto/$publicId';
  }

  // Get thumbnail URL
  String getThumbnailUrl(String publicId, {int width = 200, int height = 200}) {
    return 'https://res.cloudinary.com/$effectiveCloudName/image/fetch/w_$width,h_$height,q_auto,f_auto,c_fill/$publicId';
  }

  // Test Cloudinary configuration
  void testConfiguration() {
    print('=== Cloudinary Configuration Test ===');
    print('Cloud Name: $effectiveCloudName');
    print('Upload Preset: $effectiveUploadPreset');
    print('Is Configured: $isConfigured');

    if (!CloudinaryConfig.isValidConfig) {
      String setupMessage = '''
CLOUDINARY SETUP REQUIRED:

1. Go to: https://cloudinary.com/console
2. Find your cloud name in the URL
3. Go to Settings → Upload → Upload presets
4. Create/enable an upload preset
5. Update config in: lib/config/cloudinary_config.dart

Current values:
- Cloud Name: $effectiveCloudName
- Upload Preset: $effectiveUploadPreset
      ''';

      Get.dialog(
        Dialog(
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Cloudinary Setup Required',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                16.0.verticalSpace,
                Text(
                  setupMessage,
                  style: TextStyle(fontSize: 12.sp),
                ),
                16.0.verticalSpace,
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('I Understand'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Get.snackbar(
        '✅ Configuration OK',
        'Cloudinary is ready:\nCloud: $effectiveCloudName\nPreset: $effectiveUploadPreset',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Show image picker bottom sheet
  Future<File?> showImagePickerOptions(BuildContext context) async {
    return await showModalBottomSheet<File>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.of(context).pop(await pickImageFromCamera());
                    },
                  ),
                  _ImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.of(context).pop(await pickImageFromGallery());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
