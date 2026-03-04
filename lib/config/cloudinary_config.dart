class CloudinaryConfig {
  // ====================================================================
  // CLOUDINARY SETUP INSTRUCTIONS
  // ====================================================================
  // 1. Go to your Cloudinary dashboard (https://cloudinary.com/console)
  // 2. Your cloud name is in the dashboard URL: https://cloudinary.com/console/YOUR_CLOUD_NAME
  // 3. Go to Settings -> Upload -> Upload presets
  // 4. Create a new upload preset or use an existing one
  // 5. Make sure the preset allows "Unsigned uploading"
  // 6. Replace the values below with your actual cloud name and upload preset

  // Example: If your dashboard URL is https://cloudinary.com/console/mycompany123
  // Then your cloud name is: mycompany123

  static const String cloudName =
      'dn1nx5buv'; // Replace with your actual cloud name
  static const String uploadPreset =
      'biogas_app'; // Replace with your actual upload preset

  const CloudinaryConfig._();

  // Helper method to validate configuration
  static bool get isValidConfig =>
      cloudName != 'dn1nx5buv' &&
      uploadPreset != 'biogas_app' &&
      cloudName.isNotEmpty &&
      uploadPreset.isNotEmpty;
}
