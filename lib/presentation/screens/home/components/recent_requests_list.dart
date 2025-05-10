// lib/presentation/screens/home/components/recent_requests_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/service_request_view_model.dart';
import 'request_card.dart';
import 'empty_requests_state.dart';

class RecentRequestsList extends StatelessWidget {
  const RecentRequestsList({Key? key}) : super(key: key);

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

        if (requestViewModel.userRequests.isEmpty) {
          return const EmptyRequestsState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requestViewModel.userRequests.length,
          itemBuilder: (context, index) {
            final request = requestViewModel.userRequests[index];
            return RequestCard(request: request);
          },
        );
      },
    );
  }
}
