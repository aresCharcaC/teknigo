// lib/presentation/screens/home/components/request_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/category_view_model.dart';
import '../../../view_models/service_request_view_model.dart';
import '../../service_request/service_request_detail_screen.dart';
import 'request_utils.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequestModel request;

  const RequestCard({Key? key, required this.request}) : super(key: key);

  // Confirm deletion of request
  Future<void> _confirmDelete(
    BuildContext context,
    String requestId,
    ServiceRequestViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar solicitud'),
            content: const Text(
              '¿Estás seguro de que deseas cancelar esta solicitud?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('SÍ, CANCELAR'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await viewModel.cancelServiceRequest(requestId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud cancelada correctamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar la solicitud: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestViewModel = Provider.of<ServiceRequestViewModel>(
      context,
      listen: false,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to request detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ServiceRequestDetailScreen(requestId: request.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RequestUtils.getStatusColor(request.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      RequestUtils.getStatusText(request.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    RequestUtils.formatDate(request.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title and urgency
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon (using the first category)
                  Consumer<CategoryViewModel>(
                    builder: (context, categoryViewModel, child) {
                      CategoryModel? category;
                      if (request.categoryIds.isNotEmpty) {
                        category = categoryViewModel.categories.firstWhere(
                          (c) => c.id == request.categoryIds.first,
                          orElse:
                              () =>
                                  categoryViewModel.categories.isNotEmpty
                                      ? categoryViewModel.categories.first
                                      : CategoryModel(
                                        id: '',
                                        name: '',
                                        iconName: 'build',
                                        iconColor: Colors.grey,
                                        tags: [],
                                        isActive: true,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category?.iconColor ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category?.getIcon() ?? Icons.build,
                          color: Colors.white,
                          size: 16,
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          request.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Urgency and location
              Row(
                children: [
                  if (request.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'URGENTE',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (request.isUrgent) const SizedBox(width: 8),

                  Icon(
                    request.inClientLocation ? Icons.home : Icons.store,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    request.inClientLocation
                        ? 'En tu ubicación'
                        : 'En local del técnico',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),

                  const Spacer(),

                  // Delete button
                  if (request.status == 'pending')
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed:
                          () => _confirmDelete(
                            context,
                            request.id,
                            requestViewModel,
                          ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
