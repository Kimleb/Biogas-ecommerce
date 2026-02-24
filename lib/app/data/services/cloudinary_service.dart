import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryService extends GetxService {
  static CloudinaryService get to => Get.find();

  final ImagePicker _imagePicker = ImagePicker();

  // Cloudinary configuration - replace with your actual credentials
  static const String cloudName = 'Root';
  static const String apiKey = '429824777814863';
  static const String apiSecret = 'f6y6PSACADNkk3ivJQiZjzUPOF4';
  static const String uploadPreset = 'biogas_app'; // Create this in your Cloudinary dashboard

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
  Future<String?> uploadImage(File imageFile, {String folder = 'biogas_app'}) async {
    try {
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
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
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
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Parse response (simple parsing for secure_url)
        final urlMatch = RegExp(r'"secure_url":"([^"]+)"').firstMatch(responseBody);
        if (urlMatch != null) {
          final secureUrl = urlMatch.group(1)?.replaceAll(r'\/', '/');
          if (secureUrl != null) {
            Get.snackbar(
              'Success',
              'Image uploaded successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            return secureUrl;
          }
        }
        throw Exception('Failed to parse upload response');
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, {String folder = 'biogas_app'}) async {
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
  String getOptimizedImageUrl(String publicId, {int width = 800, int height = 600}) {
    return 'https://res.cloudinary.com/$cloudName/image/fetch/w_$width,h_$height,q_auto,f_auto/$publicId';
  }

  // Get thumbnail URL
  String getThumbnailUrl(String publicId, {int width = 200, int height = 200}) {
    return 'https://res.cloudinary.com/$cloudName/image/fetch/w_$width,h_$height,q_auto,f_auto,c_fill/$publicId';
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
