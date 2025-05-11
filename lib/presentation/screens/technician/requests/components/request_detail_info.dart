// lib/presentation/screens/technician/requests/components/request_detail_info.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/models/service_request_model.dart';
import '../../../../view_models/category_view_model.dart';

class RequestDetailInfo extends StatelessWidget {
  final ServiceRequestModel request;

  const RequestDetailInfo({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Categorías
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.category, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Categorías:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Consumer<CategoryViewModel>(
                    builder: (context, categoryViewModel, child) {
                      final categoryNames = request.categoryIds
                          .map((id) {
                            final category = categoryViewModel.categories
                                .firstWhere(
                                  (c) => c.id == id,
                                  orElse:
                                      () => categoryViewModel.categories.first,
                                );

                            return category.name;
                          })
                          .join(', ');

                      return Text(
                        categoryNames.isNotEmpty
                            ? categoryNames
                            : 'No especificadas',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Urgencia
            Row(
              children: [
                Icon(Icons.timer, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Urgencia:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 8),
                Text(
                  request.isUrgent ? 'Urgente (para hoy)' : 'Normal',
                  style: TextStyle(
                    fontSize: 15,
                    color: request.isUrgent ? Colors.red : Colors.grey.shade800,
                    fontWeight:
                        request.isUrgent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  request.inClientLocation ? Icons.home : Icons.store,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ubicación:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.inClientLocation
                            ? 'En domicilio del cliente'
                            : 'En tu local',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (request.inClientLocation &&
                          request.address != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          request.address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Fecha programada (si existe)
            if (request.scheduledDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Fecha programada:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(request.scheduledDate!),
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
