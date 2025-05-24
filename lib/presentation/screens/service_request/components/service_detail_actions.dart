import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/service_request_view_model.dart';
import '../edit_service_request_screen.dart';

class ServiceDetailActions extends StatelessWidget {
  final ServiceRequestModel request;

  const ServiceDetailActions({Key? key, required this.request})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Solo mostrar acciones si el estado permite interacción
    final canEdit = request.status == 'pending';
    final canCancel = ['pending', 'offered'].contains(request.status);

    if (!canEdit && !canCancel) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                // Botón Editar
                if (canEdit) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editRequest(context),
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Editar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  if (canCancel) const SizedBox(width: 12),
                ],

                // Botón Cancelar/Eliminar
                if (canCancel) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmCancel(context),
                      icon: const Icon(Icons.cancel),
                      label: Text(
                        request.status == 'pending' ? 'Eliminar' : 'Cancelar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Texto informativo
            Text(
              _getActionInfoText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getActionInfoText() {
    if (request.status == 'pending') {
      return 'Puedes editar o eliminar esta solicitud mientras no haya propuestas.';
    } else if (request.status == 'offered') {
      return 'Ya hay propuestas para esta solicitud. Solo puedes cancelarla.';
    }
    return '';
  }

  void _editRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceRequestScreen(request: request),
      ),
    ).then((edited) {
      // Si se editó la solicitud, actualizar la vista
      if (edited == true) {
        final requestViewModel = Provider.of<ServiceRequestViewModel>(
          context,
          listen: false,
        );
        requestViewModel.getServiceRequestById(request.id);
      }
    });
  }

  void _confirmCancel(BuildContext context) {
    final actionText = request.status == 'pending' ? 'eliminar' : 'cancelar';
    final actionTextCaps =
        request.status == 'pending' ? 'ELIMINAR' : 'CANCELAR';

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              '${actionTextCaps.toLowerCase().capitalizeFirst()} solicitud',
            ),
            content: Text(
              '¿Estás seguro de que deseas $actionText esta solicitud?${request.status == 'pending' ? ' Esta acción no se puede deshacer.' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _cancelRequest(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(actionTextCaps),
              ),
            ],
          ),
    );
  }

  Future<void> _cancelRequest(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );

      final result = await requestViewModel.deleteServiceRequest(request.id);

      // Cerrar indicador de carga
      if (context.mounted) Navigator.pop(context);

      if (result.isSuccess) {
        // Mostrar mensaje de éxito
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                request.status == 'pending'
                    ? 'Solicitud eliminada correctamente'
                    : 'Solicitud cancelada correctamente',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Volver a la pantalla anterior
          Navigator.pop(context);
        }
      } else {
        // Mostrar error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de carga en caso de error
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// Extension para capitalizar primera letra
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
