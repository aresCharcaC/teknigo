// lib/presentation/screens/technician/components/technician_service_status_card.dart
// Versión directa sin diálogos intermedios

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/service_enums.dart';
import '../../../../core/models/service_model.dart';
import '../../../view_models/service_status_view_model.dart';

class TechnicianServiceStatusCard extends StatelessWidget {
  final String chatId;

  const TechnicianServiceStatusCard({Key? key, required this.chatId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener viewModel de manera segura
    final viewModel = Provider.of<ServiceStatusViewModel>(context);

    // Si está cargando y no hay servicio, mostrar indicador
    if (viewModel.isLoading && viewModel.currentService == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Si no hay servicio asociado a este chat
    if (viewModel.currentService == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.blue.shade800, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Chat de servicio técnico',
                style: TextStyle(color: Colors.blue.shade800),
              ),
            ),
          ],
        ),
      );
    }

    // Si hay servicio, mostrar tarjeta con estado y botón de edición
    final service = viewModel.currentService!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(service.status).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: _getStatusColor(service.status), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Icono de estado
          Icon(
            _getStatusIcon(service.status),
            color: _getStatusColor(service.status),
            size: 24,
          ),
          const SizedBox(width: 8),

          // Texto del estado
          Expanded(
            child: Text(
              _getStatusText(service.status),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),

          // Precio si está disponible
          if (service.agreedPrice != null)
            Text(
              'S/ ${service.agreedPrice!.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

          // Botón de edición siempre visible para el técnico
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            tooltip: 'Cambiar estado',
            onPressed: () {
              // Mostrar diálogo con todos los estados disponibles sin confirmaciones
              _showStatusChangeDialog(context, viewModel);
            },
          ),
        ],
      ),
    );
  }

  // Obtener estados disponibles (todos menos el actual y RATED)
  List<ServiceStatus> _getAvailableStatuses(ServiceStatus currentStatus) {
    // Lista base de todos los estados posibles
    List<ServiceStatus> allStatuses = [
      ServiceStatus.pending,
      ServiceStatus.offered,
      ServiceStatus.accepted,
      ServiceStatus.inProgress,
      ServiceStatus.completed,
      ServiceStatus.cancelled,
      ServiceStatus.rejected,
    ];

    // Filtrar el estado actual (no permitir cambiar al mismo estado)
    allStatuses.removeWhere((status) => status == currentStatus);

    // No permitir pasar directamente a "rated" (solo el cliente puede hacerlo)
    allStatuses.removeWhere((status) => status == ServiceStatus.rated);

    return allStatuses;
  }

  // Mostrar diálogo para cambiar estado - SIN CONFIRMACIONES ADICIONALES
  void _showStatusChangeDialog(
    BuildContext context,
    ServiceStatusViewModel viewModel,
  ) {
    // Capturar una referencia al viewModel
    final serviceViewModel = viewModel;
    final currentStatus =
        viewModel.currentService?.status ?? ServiceStatus.pending;

    // Obtener todos los estados disponibles
    List<ServiceStatus> availableStatuses = _getAvailableStatuses(
      currentStatus,
    );

    // Mostrar diálogo simple con lista de estados
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Cambiar estado del servicio'),
          content: Container(
            width: double.maxFinite,
            height: 300, // Altura fija para la lista
            child: ListView(
              shrinkWrap: true,
              children:
                  availableStatuses.map((status) {
                    return ListTile(
                      leading: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                      ),
                      title: Text(_getStatusText(status)),
                      onTap: () async {
                        // Cerrar el diálogo primero
                        Navigator.pop(dialogContext);

                        // CASO ESPECIAL: si el estado seleccionado es COMPLETED
                        if (status == ServiceStatus.completed) {
                          // Usar completeService que enviará el mensaje especial al cliente
                          final result =
                              await serviceViewModel.completeService();

                          // Mostrar mensaje de éxito o error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.isSuccess
                                      ? 'Se ha enviado una solicitud de confirmación al cliente'
                                      : (result.error ??
                                          'Error al marcar como completado'),
                                ),
                                backgroundColor:
                                    result.isSuccess
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            );
                          }
                        }
                        // Para todos los demás estados, cambiar directamente
                        else {
                          // Cambiar estado directamente sin confirmación
                          final result = await serviceViewModel
                              .changeServiceStatus(status);

                          // Mostrar mensaje de éxito o error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.isSuccess
                                      ? 'Estado cambiado a ${_getStatusText(status)}'
                                      : (result.error ??
                                          'Error al cambiar el estado'),
                                ),
                                backgroundColor:
                                    result.isSuccess
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('CANCELAR'),
            ),
          ],
        );
      },
    );
  }

  // Obtener color según estado
  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Colors.grey;
      case ServiceStatus.offered:
        return Colors.blue;
      case ServiceStatus.accepted:
        return Colors.purple;
      case ServiceStatus.inProgress:
        return Colors.orange;
      case ServiceStatus.completed:
        return Colors.green;
      case ServiceStatus.rated:
        return Colors.amber;
      case ServiceStatus.cancelled:
        return Colors.red;
      case ServiceStatus.rejected:
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  // Obtener icono según estado
  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Icons.hourglass_empty;
      case ServiceStatus.offered:
        return Icons.local_offer;
      case ServiceStatus.accepted:
        return Icons.handshake;
      case ServiceStatus.inProgress:
        return Icons.engineering;
      case ServiceStatus.completed:
        return Icons.check_circle;
      case ServiceStatus.rated:
        return Icons.star;
      case ServiceStatus.cancelled:
        return Icons.cancel;
      case ServiceStatus.rejected:
        return Icons.thumb_down;
      default:
        return Icons.help_outline;
    }
  }

  // Obtener texto según estado
  String _getStatusText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return 'PENDIENTE';
      case ServiceStatus.offered:
        return 'PROPUESTA ENVIADA';
      case ServiceStatus.accepted:
        return 'SERVICIO ACEPTADO';
      case ServiceStatus.inProgress:
        return 'TRABAJO EN PROGRESO';
      case ServiceStatus.completed:
        return 'TRABAJO COMPLETADO';
      case ServiceStatus.rated:
        return 'SERVICIO FINALIZADO';
      case ServiceStatus.cancelled:
        return 'SERVICIO CANCELADO';
      case ServiceStatus.rejected:
        return 'PROPUESTA RECHAZADA';
      default:
        return 'ESTADO DESCONOCIDO';
    }
  }
}
