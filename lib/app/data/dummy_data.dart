import 'models/booking_model.dart';
import 'models/part_model.dart';
import 'models/user_model.dart';

class DummyData {
  // Sample Parts/Goods for Repairs
  static List<PartModel> parts = [
    PartModel(
      id: '1',
      name: 'Biogas Burner',
      description: 'High-efficiency biogas burner for cooking',
      price: 45.00,
      category: 'Burners',
      quantity: 10,
    ),
    PartModel(
      id: '2',
      name: 'Gas Pressure Regulator',
      description: 'Adjustable pressure regulator for biogas systems',
      price: 35.00,
      category: 'Regulators',
      quantity: 15,
    ),
    PartModel(
      id: '3',
      name: 'Biogas Pipe (5m)',
      description: 'Durable PVC pipe for biogas transport',
      price: 25.00,
      category: 'Pipes',
      quantity: 20,
    ),
    PartModel(
      id: '4',
      name: 'Gas Valve',
      description: 'Safety valve for biogas control',
      price: 15.00,
      category: 'Valves',
      quantity: 25,
    ),
    PartModel(
      id: '5',
      name: 'Digester Seal',
      description: 'Rubber seal for biogas digester',
      price: 20.00,
      category: 'Seals',
      quantity: 30,
    ),
    PartModel(
      id: '6',
      name: 'Gas Filter',
      description: 'H2S removal filter for biogas purification',
      price: 55.00,
      category: 'Filters',
      quantity: 12,
    ),
    PartModel(
      id: '7',
      name: 'Pressure Gauge',
      description: 'Digital pressure gauge for monitoring',
      price: 30.00,
      category: 'Gauges',
      quantity: 18,
    ),
    PartModel(
      id: '8',
      name: 'Gas Hose (3m)',
      description: 'Flexible gas hose with fittings',
      price: 18.00,
      category: 'Hoses',
      quantity: 22,
    ),
  ];

  // Sample Users
  static List<UserModel> users = [
    UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+1234567890',
      role: 'customer',
      address: '123 Main St, City',
    ),
    UserModel(
      id: '2',
      name: 'Mike Johnson',
      email: 'mike@example.com',
      phone: '+1234567891',
      role: 'technician',
      rating: 4.8,
      completedJobs: 45,
    ),
    UserModel(
      id: '3',
      name: 'Sarah Williams',
      email: 'sarah@example.com',
      phone: '+1234567892',
      role: 'technician',
      rating: 4.9,
      completedJobs: 62,
    ),
    UserModel(
      id: '4',
      name: 'Admin User',
      email: 'admin@biogas.com',
      phone: '+1234567893',
      role: 'admin',
    ),
  ];

  // Sample Bookings
  static List<BookingModel> bookings = [
    BookingModel(
      id: '1',
      customerId: '1',
      customerName: 'John Doe',
      serviceId: '1',
      serviceName: 'Biogas Installation',
      technicianId: '2',
      technicianName: 'Mike Johnson',
      bookingDate: DateTime.now().subtract(Duration(days: 2)),
      serviceDate: DateTime.now().add(Duration(days: 1)),
      status: 'confirmed',
      totalPrice: 150.00,
      address: '123 Main St, City',
      notes: 'Need installation for home biogas system',
      selectedParts: [],
    ),
    BookingModel(
      id: '2',
      customerId: '1',
      customerName: 'John Doe',
      serviceId: '2',
      serviceName: 'Biogas Maintenance',
      technicianId: '3',
      technicianName: 'Sarah Williams',
      bookingDate: DateTime.now().subtract(Duration(days: 5)),
      serviceDate: DateTime.now().subtract(Duration(days: 3)),
      status: 'completed',
      totalPrice: 85.00,
      address: '123 Main St, City',
      selectedParts: [
        PartModel(
          id: '4',
          name: 'Gas Valve',
          description: 'Safety valve for biogas control',
          price: 15.00,
          category: 'Valves',
          quantity: 2,
        ),
      ],
      rating: '5',
      review: 'Excellent service, very professional!',
    ),
  ];

  static UserModel? currentUser;

  static void setCurrentUser(UserModel user) {
    currentUser = user;
  }

  static UserModel getCurrentUser() {
    return currentUser ?? users[0]; // Default to first customer
  }

  static List<BookingModel> getBookingsForUser(String userId, String role) {
    if (role == 'admin') {
      return bookings;
    } else if (role == 'technician') {
      return bookings.where((b) => b.technicianId == userId).toList();
    } else {
      return bookings.where((b) => b.customerId == userId).toList();
    }
  }

  static List<UserModel> getTechnicians() {
    return users.where((u) => u.role == 'technician').toList();
  }
}
