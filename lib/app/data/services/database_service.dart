import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';

class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Services Collection
  DatabaseReference get servicesRef => _database.ref().child('services');
  DatabaseReference get bookingsRef => _database.ref().child('bookings');
  DatabaseReference get partsRef => _database.ref().child('parts');

  // CRUD Operations for Services
  Future<void> addService(ServiceModel service) async {
    try {
      await servicesRef.child(service.id.toString()).set({
        'id': service.id,
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
        'image': service.primaryImage,
        'technicianId': service.technicianId,
        'technicianName': service.technicianName,
        'rating': service.rating,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      await servicesRef.child(service.id.toString()).update({
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
        'image': service.primaryImage,
        'technicianId': service.technicianId,
        'technicianName': service.technicianName,
        'rating': service.rating,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
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
      final snapshot = await servicesRef.get();
      List<ServiceModel> services = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          services.add(ServiceModel.fromJson(Map<String, dynamic>.from(value)));
        });
      }
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
      final snapshot =
          await bookingsRef.orderByChild('userId').equalTo(userId).get();
      List<BookingModel> bookings = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          bookings.add(BookingModel.fromJson(Map<String, dynamic>.from(value)));
        });
      }
      return bookings;
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
    }
  }

  Future<List<BookingModel>> getTechnicianBookings(String technicianId) async {
    try {
      final snapshot = await bookingsRef
          .orderByChild('technicianId')
          .equalTo(technicianId)
          .get();
      List<BookingModel> bookings = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          bookings.add(BookingModel.fromJson(Map<String, dynamic>.from(value)));
        });
      }
      return bookings;
    } catch (e) {
      print('Error getting technician bookings: $e');
      return [];
    }
  }

  Future<List<BookingModel>> getAllBookings() async {
    try {
      final snapshot = await bookingsRef.get();
      List<BookingModel> bookings = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          bookings.add(BookingModel.fromJson(Map<String, dynamic>.from(value)));
        });
      }
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
      final snapshot = await partsRef.get();
      List<Map<String, dynamic>> parts = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          parts.add(Map<String, dynamic>.from(value));
        });
      }
      return parts;
    } catch (e) {
      print('Error getting parts: $e');
      return [];
    }
  }

  // Stream methods for real-time updates
  Stream<DatabaseEvent> getServicesStream() {
    return servicesRef.onValue;
  }

  Stream<DatabaseEvent> getBookingsStream() {
    return bookingsRef.onValue;
  }

  Stream<DatabaseEvent> getPartsStream() {
    return partsRef.onValue;
  }
}
