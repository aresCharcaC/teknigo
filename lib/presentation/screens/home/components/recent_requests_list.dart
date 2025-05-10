// lib/presentation/screens/home/components/recent_requests_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/service_request_view_model.dart';
import 'request_card.dart';
import 'empty_requests_state.dart';

class RecentRequestsList extends StatefulWidget {
  const RecentRequestsList({Key? key}) : super(key: key);

  @override
  _RecentRequestsListState createState() => _RecentRequestsListState();
}

class _RecentRequestsListState extends State<RecentRequestsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force a reload when the widget first builds
      final viewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );
      viewModel.reloadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceRequestViewModel>(
      builder: (context, requestViewModel, child) {
        if (requestViewModel.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (requestViewModel.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${requestViewModel.errorMessage}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => requestViewModel.reloadRequests(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (requestViewModel.userRequests.isEmpty) {
          return const EmptyRequestsState();
        }

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requestViewModel.userRequests.length,
              itemBuilder: (context, index) {
                final request = requestViewModel.userRequests[index];
                return RequestCard(request: request);
              },
            ),
            // Add a bottom message to let users know how many requests they have
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Mostrando ${requestViewModel.userRequests.length} solicitud(es)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
