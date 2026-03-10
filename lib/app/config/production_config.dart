class ProductionConfig {
  // App configuration
  static const String appName = 'Biogas E-Commerce';
  static const String appVersion = '1.0.0';
  
  // API timeouts and limits
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImagesPerItem = 5;
  static const int maxRetryAttempts = 3;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache settings
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int maxCacheSize = 100; // Maximum items in cache
  
  // Validation limits
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxNotesLength = 500;
  static const double maxPrice = 999999.99;
  static const int maxQuantity = 999999;
  
  // Security settings
  static const bool enableInputSanitization = true;
  static const bool enableRateLimiting = true;
  static const int maxRequestsPerMinute = 60;
  
  // Performance settings
  static const bool enableImageCompression = true;
  static const double imageQuality = 0.8;
  static const int thumbnailSize = 200;
  
  // Logging settings
  static const bool enableDetailedLogging = false; // Set to false in production
  static const bool enableErrorReporting = true;
  
  // Database settings
  static const bool enableOfflinePersistence = true;
  static const int databaseCacheSize = 10 * 1024 * 1024; // 10MB
  
  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
}
