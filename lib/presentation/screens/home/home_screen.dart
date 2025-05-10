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

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for app lifecycle

    // Load categories and service requests
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload data when app resumes
    if (state == AppLifecycleState.resumed) {
      print("App resumed - reloading data");
      _reloadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  // Initial load of data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load categories
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );
      await categoryViewModel.loadCategories();

      // Load service requests
      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );
      await requestViewModel.loadUserServiceRequests();
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Force reload data
  Future<void> _reloadData() async {
    try {
      // Explicitly reload service requests
      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );
      await requestViewModel.reloadRequests();
    } catch (e) {
      print('Error reloading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Determine if we're still setting up providers
    final bool isInitializing = _isLoading;

    return RefreshIndicator(
      onRefresh:
          _reloadData, // Use _reloadData instead of _loadData for manual refresh
      child:
          isInitializing
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Request Form
                    const ServiceRequestForm(),

                    const SizedBox(height: 24),

                    // Recent requests section with refresh button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mis solicitudes recientes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Recargar solicitudes',
                          onPressed: _reloadData,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // List of recent requests
                    const RecentRequestsList(),
                  ],
                ),
              ),
    );
  }
}
