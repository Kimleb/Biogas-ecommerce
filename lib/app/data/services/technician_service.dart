import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/technician_model.dart';

/// Technician Service for managing service providers
class TechnicianService extends GetxService {
  static TechnicianService get to => Get.find();

  // Firebase Database reference
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('technicians');

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TechnicianModel> technicians = <TechnicianModel>[].obs;

  /// Get all technicians from Firebase
  Future<void> loadTechnicians() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _databaseRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        technicians.clear();

        data.forEach((key, value) {
          final technicianData = Map<String, dynamic>.from(value);
          technicianData['id'] = key;
          technicians.add(TechnicianModel.fromJson(technicianData));
        });
      } else {
        technicians.clear();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load technicians: ${e.toString()}';
      print('Load technicians error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get technician by ID
  Future<TechnicianModel?> getTechnicianById(String technicianId) async {
    try {
      final snapshot = await _databaseRef.child(technicianId).get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = technicianId;
        return TechnicianModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Get technician error: $e');
      return null;
    }
  }

  /// Add new technician
  Future<bool> addTechnician(TechnicianModel technician) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _databaseRef.child(technician.id).set(technician.toJson());

      // Refresh the list
      await loadTechnicians();
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to add technician: ${e.toString()}';
      print('Add technician error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update technician availability
  Future<bool> updateTechnicianAvailability(
      String technicianId, bool isAvailable) async {
    try {
      await _databaseRef.child(technicianId).update({
        'is_available': isAvailable,
        'last_active': DateTime.now().toIso8601String(),
      });

      // Refresh the list
      await loadTechnicians();
      return true;
    } catch (e) {
      print('Update technician error: $e');
      return false;
    }
  }

  /// Search technicians by name or specialization
  Future<List<TechnicianModel>> searchTechnicians(String query) async {
    try {
      final snapshot = await _databaseRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final results = <TechnicianModel>[];
        final lowerQuery = query.toLowerCase();

        data.forEach((key, value) {
          final technicianData = Map<String, dynamic>.from(value);
          technicianData['id'] = key;
          final technician = TechnicianModel.fromJson(technicianData);

          if (technician.name.toLowerCase().contains(lowerQuery) ||
              (technician.specialization?.toLowerCase().contains(lowerQuery) ??
                  false)) {
            results.add(technician);
          }
        });

        return results;
      }
      return [];
    } catch (e) {
      print('Search technicians error: $e');
      return [];
    }
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Get available technicians
  List<TechnicianModel> get availableTechnicians =>
      technicians.where((tech) => tech.isAvailable).toList();
}
