import '../app/data/models/category_model.dart';
import '../app/data/models/service_model.dart';
import 'constants.dart';

class DummyHelper {
  const DummyHelper._();

  static const _description =
      'Professional biogas system services including installation, maintenance, and repair for optimal energy production and system longevity.';

  static List<Map<String, String>> cards = [
    {
      'icon': Constants.biogasRepair,
      'title': '24/7',
      'subtitle': 'Emergency Service'
    },
    {
      'icon': Constants.calendarIcon,
      'title': 'Same Day',
      'subtitle': 'Booking Available'
    },
    {
      'icon': Constants.fireIcon,
      'title': '4.9 (312)',
      'subtitle': 'Customer Rating'
    },
    {
      'icon': Constants.userIcon,
      'title': 'Certified',
      'subtitle': 'Technicians'
    },
  ];

  static List<CategoryModel> categories = [
    CategoryModel(
        id: 1,
        title: 'Repair',
        image: Constants.biogasRepair,
        description: 'Emergency repairs and troubleshooting'),
    CategoryModel(
        id: 2,
        title: 'Setup',
        image: Constants.biogasSetup,
        description: 'Professional installation and setup'),
    CategoryModel(
        id: 3,
        title: 'Purchase',
        image: Constants.biogasPurchase,
        description: 'Biogas equipment and systems'),
    CategoryModel(
        id: 4,
        title: 'Maintenance',
        image: Constants.categoryIcon,
        description: 'Regular maintenance and servicing'),
  ];

  static List<ServiceModel> services = [
    // Emergency Services
    ServiceModel(
      id: '1',
      name: 'Emergency System Repair',
      duration: '2-3 hours',
      price: 150.00,
      technicianName: 'John Smith',
      rating: 4.8,
      description:
          'Emergency repair service for biogas system malfunctions, gas leaks, and breakdowns. Available 24/7.',
    ),
    ServiceModel(
      id: '2',
      name: 'Gas Leak Detection',
      duration: '1-2 hours',
      price: 120.00,
      technicianName: 'Mike Davis',
      rating: 4.9,
      description:
          'Professional gas leak detection and repair using advanced equipment for safety compliance.',
    ),

    // Installation Services
    ServiceModel(
      id: '3',
      name: 'Complete System Installation',
      duration: '1-2 days',
      price: 2500.00,
      technicianName: 'Mike Johnson',
      rating: 4.7,
      description:
          'Full installation of biogas digestion system with all necessary components, piping, and safety checks.',
    ),
    ServiceModel(
      id: '4',
      name: 'Residential Digester Setup',
      duration: '6-8 hours',
      price: 1800.00,
      technicianName: 'Sarah Williams',
      rating: 4.6,
      description:
          'Installation of residential biogas digester with gas collection and storage system.',
    ),
    ServiceModel(
      id: '5',
      name: 'Commercial System Setup',
      duration: '2-3 days',
      price: 4500.00,
      technicianName: 'David Brown',
      rating: 4.8,
      description:
          'Large-scale commercial biogas system installation for industrial applications.',
    ),

    // Maintenance Services
    ServiceModel(
      id: '6',
      name: 'Annual Maintenance Check',
      duration: '4-6 hours',
      price: 200.00,
      technicianName: 'Sarah Williams',
      rating: 4.9,
      description:
          'Comprehensive annual maintenance including inspection, cleaning, and performance optimization.',
    ),
    ServiceModel(
      id: '7',
      name: 'System Cleaning Service',
      duration: '2-3 hours',
      price: 150.00,
      technicianName: 'Tom Wilson',
      rating: 4.7,
      description:
          'Professional cleaning of biogas system components and gas lines.',
    ),
    ServiceModel(
      id: '8',
      name: 'Performance Optimization',
      duration: '3-4 hours',
      price: 280.00,
      technicianName: 'Expert Team',
      rating: 4.8,
      description:
          'Advanced system tuning and optimization for maximum biogas production efficiency.',
    ),

    // Equipment & Products
    ServiceModel(
      id: '9',
      name: 'Biogas Digester Unit',
      duration: 'N/A',
      price: 3500.00,
      technicianName: 'Sales Team',
      rating: 4.5,
      description:
          'High-efficiency biogas digester unit for residential and small commercial use. 1000L capacity.',
    ),
    ServiceModel(
      id: '10',
      name: 'Gas Storage Tank',
      duration: 'N/A',
      price: 1200.00,
      technicianName: 'Sales Team',
      rating: 4.6,
      description:
          'Durable gas storage tank with safety valves and pressure monitoring system.',
    ),
    ServiceModel(
      id: '11',
      name: 'Gas Line Installation',
      duration: '6-8 hours',
      price: 450.00,
      technicianName: 'David Brown',
      rating: 4.9,
      description:
          'Professional gas line installation with safety inspection and leak testing.',
    ),

    // Consultation Services
    ServiceModel(
      id: '12',
      name: 'System Consultation',
      duration: '1-2 hours',
      price: 100.00,
      technicianName: 'Expert Team',
      rating: 4.8,
      description:
          'Expert consultation for biogas system planning, site assessment, and optimization recommendations.',
    ),
    ServiceModel(
      id: '13',
      name: 'Energy Audit Service',
      duration: '2-3 hours',
      price: 180.00,
      technicianName: 'Expert Team',
      rating: 4.7,
      description:
          'Complete energy audit and efficiency analysis for biogas system optimization.',
    ),
  ];

  // Keep products for backward compatibility during transition
  static List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'image': Constants.biogasRepairImg,
      'name': 'Emergency System Repair',
      'quantity': 0,
      'price': 150.00,
      'description': _description,
    },
    {
      'id': 2,
      'image': Constants.biogasSetupImg,
      'name': 'Complete System Installation',
      'quantity': 0,
      'price': 2500.00,
      'description': _description,
    },
  ];
}
