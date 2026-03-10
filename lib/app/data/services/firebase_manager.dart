import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

/// Centralized Firebase manager to ensure single database connection across entire app
class FirebaseManager extends GetxService {
  static FirebaseManager get to => Get.find();

  FirebaseDatabase get database => _database;
  late final FirebaseDatabase _database;

  // Cached stream subscriptions to prevent duplicates
  final Map<String, StreamSubscription<DatabaseEvent>> _subscriptions = {};

  // Broadcast controllers for multiple listeners
  final Map<String, StreamController<DatabaseEvent>> _controllers = {};

  FirebaseManager() {
    print('FirebaseManager: Initializing singleton instance');
    _database = FirebaseDatabase.instance;

    // Configure database settings
    _database.setPersistenceEnabled(true);
    _database.setPersistenceCacheSizeBytes(10000000); // 10MB cache
  }

  /// Get database reference with centralized management
  DatabaseReference ref([String? path]) {
    if (path != null && path.isNotEmpty) {
      return _database.ref().child(path);
    }
    return _database.ref();
  }

  /// Get stream for a specific path with subscription management
  Stream<DatabaseEvent> getStream(String path) {
    // Create broadcast controller if it doesn't exist
    _controllers.putIfAbsent(path, () {
      print('FirebaseManager: Creating new broadcast controller for $path');
      return StreamController<DatabaseEvent>.broadcast();
    });

    // Create Firebase subscription if it doesn't exist
    if (!_subscriptions.containsKey(path)) {
      print('FirebaseManager: Creating new Firebase subscription for $path');
      _subscriptions[path] =
          _database.ref().child(path).onValue.listen((event) {
        _controllers[path]?.add(event);
      }, onError: (error) {
        _controllers[path]?.addError(error);
      });
    } else {
      print(
          'FirebaseManager: Reusing existing Firebase subscription for $path');
    }

    return _controllers[path]!.stream;
  }

  /// Cancel specific subscription
  void cancelSubscription(String path) {
    print('FirebaseManager: Cancelling subscription for $path');
    _subscriptions[path]?.cancel();
    _subscriptions.remove(path);
    _controllers[path]?.close();
    _controllers.remove(path);
  }

  /// Cancel all subscriptions
  void cancelAllSubscriptions() {
    print('FirebaseManager: Cancelling all subscriptions');
    for (final path in _subscriptions.keys.toList()) {
      cancelSubscription(path);
    }
  }

  /// Get subscription count for debugging
  int get subscriptionCount => _subscriptions.length;

  @override
  void onClose() {
    print('FirebaseManager: Closing singleton instance');
    cancelAllSubscriptions();
    super.onClose();
  }
}
