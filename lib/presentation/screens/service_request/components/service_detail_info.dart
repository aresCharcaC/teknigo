import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/category_view_model.dart';

class ServiceDetailInfo extends StatelessWidget {
  final ServiceRequestModel request;

  const ServiceDetailInfo({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del Servicio',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Categorías - ARREGLADO el error de ParentDataWidget
            _buildInfoRow(
              context,
              icon: Icons.category,
              title: 'Categorías:',
              child: Consumer<CategoryViewModel>(
                builder: (context, categoryViewModel, child) {
                  if (categoryViewModel.isLoading) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  if (request.categoryIds.isEmpty) {
                    return Text(
                      'Sin categorías especificadas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }

                  // SOLUCION AL ERROR: Usar where en lugar de firstWhere
                  final categoryNames = request.categoryIds
                      .map((id) {
                        final matchingCategories =
                            categoryViewModel.categories
                                .where((c) => c.id == id)
                                .toList();

                        if (matchingCategories.isNotEmpty) {
                          return matchingCategories.first.name;
                        } else {
                          return 'Categoría ($id)'; // Mostrar ID si no se encuentra
                        }
                      })
                      .join(', ');

                  return Text(
                    categoryNames,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Urgencia
            _buildInfoRow(
              context,
              icon: Icons.timer,
              title: 'Urgencia:',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      request.isUrgent
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.isUrgent ? 'URGENTE (para hoy)' : 'Normal',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        request.isUrgent
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Ubicación - ARREGLADO: Removido Flexible que causaba el error
            _buildInfoRow(
              context,
              icon: request.inClientLocation ? Icons.home : Icons.store,
              title: 'Ubicación:',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.inClientLocation
                        ? 'En tu ubicación'
                        : 'En local del técnico',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (request.inClientLocation && request.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      request.address!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Fecha programada si existe
            if (request.scheduledDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                title: 'Fecha programada:',
                child: Text(
                  _formatDateTime(request.scheduledDate!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Número de propuestas
            _buildInfoRow(
              context,
              icon: Icons.people,
              title: 'Propuestas recibidas:',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${request.proposalCount}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        // ARREGLADO: Usar Expanded en lugar de Flexible dentro de Row
        Expanded(child: child),
      ],
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
