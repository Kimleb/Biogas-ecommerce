import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import 'firebase_manager.dart';

class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();

  // Use FirebaseManager instead of direct FirebaseDatabase
  final FirebaseDatabase _database = FirebaseManager.to.database;

  DatabaseService() {
    print('DatabaseService: Creating new instance (using FirebaseManager)');
  }

  // Services Collection
  DatabaseReference get servicesRef => _database.ref().child('services');
  DatabaseReference get bookingsRef => _database.ref().child('bookings');
  DatabaseReference get partsRef => _database.ref().child('parts');

  // CRUD Operations for Services
  Future<void> addService(ServiceModel service) async {
    try {
      final now = DateTime.now();
      await servicesRef.child(service.id.toString()).set(
            service
                .copyWith(
                  createdAt: service.createdAt ?? now,
                  updatedAt: service.updatedAt ?? now,
                )
                .toJson(),
          );
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      final now = DateTime.now();
      await servicesRef.child(service.id.toString()).update(
            service.copyWith(updatedAt: now).toJson(),
          );
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await servicesRef.child(serviceId).remove();
    } catch (e) {
      print('Error deleting service: $e');
      rethrow;
    }
  }

  Future<List<ServiceModel>> getAllServices() async {
    try {
      print('Fetching services from Firebase...');

      // Use keepSynced for better performance
      await servicesRef.keepSynced(true);
      final snapshot = await servicesRef.get();

      print('Services snapshot exists: ${snapshot.exists}');

      if (!snapshot.exists) {
        print('No services found in database');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      print('Services data keys: ${data.keys}');

      final services = <ServiceModel>[];

      // Process services in parallel for better performance
      final futures = data.entries.map((entry) async {
        try {
          final serviceData = Map<String, dynamic>.from(entry.value);
          final service = ServiceModel.fromJson(serviceData);
          print('Processed service: ${service.name}');
          return service;
        } catch (e) {
          print('Error processing service ${entry.key}: $e');
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);
      services.addAll(
          results.where((service) => service != null).cast<ServiceModel>());

      print('Total services loaded: ${services.length}');
      return services;
    } catch (e) {
      print('Error getting services: $e');
      return [];
    }
  }

  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final snapshot = await servicesRef.child(serviceId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return ServiceModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      print('Error getting service: $e');
      return null;
    }
  }

  // CRUD Operations for Bookings
  Future<void> addBooking(BookingModel booking) async {
    try {
      await bookingsRef.child(booking.id).set({
        'id': booking.id,
        'serviceId': booking.serviceId,
        'customerId': booking.customerId,
        'technicianId': booking.technicianId,
        'bookingDate': booking.bookingDate.millisecondsSinceEpoch,
        'status': booking.status,
        'totalPrice': booking.totalPrice,
        'notes': booking.notes,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error adding booking: $e');
      rethrow;
    }
  }

  Future<void> updateBooking(BookingModel booking) async {
    try {
      await bookingsRef.child(booking.id).update({
        'status': booking.status,
        'notes': booking.notes,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating booking: $e');
      rethrow;
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await bookingsRef.child(bookingId).remove();
    } catch (e) {
      print('Error deleting booking: $e');
      rethrow;
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      // Fetch all bookings and filter client-side to avoid index requirement
      final snapshot = await bookingsRef.get();
      List<BookingModel> bookings = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        // Process bookings asynchronously to avoid blocking main thread
        final futures = data.entries.map((entry) async {
          try {
            final bookingData = Map<String, dynamic>.from(entry.value);
            final booking = BookingModel.fromJson(bookingData);
            // Filter bookings for the current user
            return booking.customerId == userId ? booking : null;
          } catch (e) {
            print('Error processing booking ${entry.key}: $e');
            return null;
          }
        }).toList();

        final results = await Future.wait(futures);
        bookings.addAll(
            results.where((booking) => booking != null).cast<BookingModel>());
      }
      return bookings;
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
    }
  }

  Future<List<BookingModel>> getTechnicianBookings(String technicianId) async {
    try {
      // Fetch all bookings and filter client-side to avoid index requirement
      final snapshot = await bookingsRef.get();
      List<BookingModel> bookings = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        // Process bookings asynchronously to avoid blocking main thread
        final futures = data.entries.map((entry) async {
          try {
            final bookingData = Map<String, dynamic>.from(entry.value);
            final booking = BookingModel.fromJson(bookingData);
            // Filter bookings for the current technician
            return booking.technicianId == technicianId ? booking : null;
          } catch (e) {
            print('Error processing booking ${entry.key}: $e');
            return null;
          }
        }).toList();

        final results = await Future.wait(futures);
        bookings.addAll(
            results.where((booking) => booking != null).cast<BookingModel>());
      }
      return bookings;
    } catch (e) {
      print('Error getting technician bookings: $e');
      return [];
    }
  }

  Future<List<BookingModel>> getAllBookings() async {
    try {
      print('Fetching bookings from Firebase...');

      // Use keepSynced for better performance
      await bookingsRef.keepSynced(true);
      final snapshot = await bookingsRef.get();

      print('Bookings snapshot exists: ${snapshot.exists}');

      if (!snapshot.exists) {
        print('No bookings found in database');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      print('Bookings data keys: ${data.keys}');

      final bookings = <BookingModel>[];

      // Process bookings in parallel for better performance
      final futures = data.entries.map((entry) async {
        try {
          final bookingData = Map<String, dynamic>.from(entry.value);
          final booking = BookingModel.fromJson(bookingData);
          print('Processed booking: ${booking.id}');
          return booking;
        } catch (e) {
          print('Error processing booking ${entry.key}: $e');
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);
      bookings.addAll(
          results.where((booking) => booking != null).cast<BookingModel>());

      print('Total bookings loaded: ${bookings.length}');
      return bookings;
    } catch (e) {
      print('Error getting all bookings: $e');
      return [];
    }
  }

  // CRUD Operations for Parts
  Future<void> addPart(Map<String, dynamic> part) async {
    try {
      await partsRef.child(part['id']).set({
        ...part,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error adding part: $e');
      rethrow;
    }
  }

  Future<void> updatePart(String partId, Map<String, dynamic> updates) async {
    try {
      await partsRef.child(partId).update({
        ...updates,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating part: $e');
      rethrow;
    }
  }

  Future<void> deletePart(String partId) async {
    try {
      await partsRef.child(partId).remove();
    } catch (e) {
      print('Error deleting part: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllParts() async {
    try {
      print('Fetching parts from Firebase...');

      // Use keepSynced for better performance
      await partsRef.keepSynced(true);
      final snapshot = await partsRef.get();

      print('Parts snapshot exists: ${snapshot.exists}');

      if (!snapshot.exists) {
        print('No parts found in database');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      print('Parts data keys: ${data.keys}');

      final parts = <Map<String, dynamic>>[];

      // Process parts in parallel for better performance
      final futures = data.entries.map((entry) async {
        try {
          final partData = Map<String, dynamic>.from(entry.value);
          print('Processed part: ${partData['name'] ?? 'Unknown'}');
          return partData;
        } catch (e) {
          print('Error processing part ${entry.key}: $e');
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);
      parts.addAll(
          results.where((part) => part != null).cast<Map<String, dynamic>>());

      print('Total parts loaded: ${parts.length}');
      return parts;
    } catch (e) {
      print('Error getting parts: $e');
      return [];
    }
  }

  // Stream methods for real-time updates - now using FirebaseManager
  Stream<DatabaseEvent> getServicesStream() {
    return FirebaseManager.to.getStream('services');
  }

  Stream<DatabaseEvent> getBookingsStream() {
    return FirebaseManager.to.getStream('bookings');
  }

  Stream<DatabaseEvent> getPartsStream() {
    return FirebaseManager.to.getStream('parts');
  }

  // Method to clear cached streams (for testing or cleanup)
  void clearCachedStreams() {
    FirebaseManager.to.cancelAllSubscriptions();
  }

  @override
  void onClose() {
    clearCachedStreams();
    super.onClose();
  }
}
