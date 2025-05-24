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

  // MÉTODO DE ELIMINACIÓN SIMPLIFICADO Y FUNCIONAL
  Future<void> _confirmDelete(
    BuildContext context,
    String requestId,
    ServiceRequestViewModel viewModel,
  ) async {
    try {
      print("Iniciando confirmación de eliminación para: $requestId");

      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Eliminar solicitud'),
              content: const Text(
                '¿Estás seguro de que deseas eliminar esta solicitud? Esta acción no se puede deshacer y eliminará todos los datos relacionados, incluyendo las fotos.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('NO'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('SÍ, ELIMINAR'),
                ),
              ],
            ),
      );

      print("Resultado del diálogo: $confirmed");

      // Si el usuario confirmó la eliminación
      if (confirmed == true && context.mounted) {
        // Mostrar indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        print("Llamando deleteServiceRequest");

        // Intentar eliminar la solicitud
        final result = await viewModel.deleteServiceRequest(requestId);

        // Cerrar indicador de carga
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Mostrar resultado
        if (context.mounted) {
          if (result.isSuccess) {
            print("Eliminación exitosa");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitud eliminada correctamente'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Forzar recarga de datos
            viewModel.reloadRequests();
          } else {
            print("Error en eliminación: ${result.error}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al eliminar la solicitud: ${result.error}',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Excepción en _confirmDelete: $e");

      // Asegurar que cerramos cualquier diálogo de carga abierto
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la solicitud: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ViewModel directamente en el build
    final requestViewModel = Provider.of<ServiceRequestViewModel>(
      context,
      listen: false,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a detalles
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ServiceRequestDetailScreen(requestId: request.id),
            ),
          ).then((_) {
            // Recargar datos cuando regrese
            requestViewModel.reloadRequests();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado y fecha
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

              // Título e icono de categoría
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de categoría
                  Consumer<CategoryViewModel>(
                    builder: (context, categoryViewModel, child) {
                      CategoryModel? category;
                      if (request.categoryIds.isNotEmpty) {
                        try {
                          category = categoryViewModel.categories.firstWhere(
                            (c) => c.id == request.categoryIds.first,
                          );
                        } catch (e) {
                          category = null;
                        }
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

                  // Título y descripción
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

              // Urgencia y ubicación
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

                  // Botón eliminar - SIMPLIFICADO
                  GestureDetector(
                    onTap:
                        () => _confirmDelete(
                          context,
                          request.id,
                          requestViewModel,
                        ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
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
