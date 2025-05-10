// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service_request_model.dart';
import '../../view_models/category_view_model.dart';
import '../../view_models/service_request_view_model.dart';
import 'components/service_request_form.dart';
import 'components/recent_requests_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Load categories and service requests
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );
      categoryViewModel.loadCategories();

      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );
      requestViewModel.loadUserServiceRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Request Form
          const ServiceRequestForm(),

          const SizedBox(height: 24),

          // Recent requests section
          const Text(
            'Mis solicitudes recientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // List of recent requests
          const RecentRequestsList(),
        ],
      ),
    );
  }
}
