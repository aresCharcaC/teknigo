// lib/presentation/screens/technician/components/technician_service_status_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/service_enums.dart';
import '../../../../core/models/service_model.dart';
import '../../../view_models/service_status_view_model.dart';
import '../../../common/resource.dart';

class TechnicianServiceStatusCard extends StatelessWidget {
  final String chatId;

  const TechnicianServiceStatusCard({Key? key, required this.chatId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building TechnicianServiceStatusCard for chatId: $chatId");

    return Consumer<ServiceStatusViewModel>(
      builder: (context, viewModel, child) {
        print(
          "ServiceViewModel state: ${viewModel.state}, hasService: ${viewModel.currentService != null}",
        );

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
          print("No hay servicio asociado al chat");
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
        print("Servicio encontrado con estado: ${service.status}");

        // Verificar si es el técnico - siempre habilitamos el botón para el técnico
        bool canEdit = true; // Siempre mostrar botón de edición en modo técnico

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(service.status).withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: _getStatusColor(service.status),
                width: 1,
              ),
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
                  print("Botón de edición presionado");
                  _showStatusChangeDialog(context, viewModel, service.status);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Mostrar diálogo para cambiar estado
  void _showStatusChangeDialog(
    BuildContext context,
    ServiceStatusViewModel viewModel,
    ServiceStatus currentStatus,
  ) {
    print("Showing status change dialog for status: $currentStatus");

    // Determinar siguiente estado posible y otras opciones disponibles
    List<ServiceStatus> availableStatuses = _getAvailableStatuses(
      currentStatus,
    );

    if (availableStatuses.isEmpty) {
      // Si no hay estados disponibles, mostrar un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se puede cambiar el estado actual'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar un diálogo con las opciones de estado disponibles
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar estado del servicio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                availableStatuses.map((status) {
                  return ListTile(
                    leading: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                    ),
                    title: Text(_getStatusText(status)),
                    onTap: () {
                      Navigator.pop(context);
                      _changeServiceStatus(context, viewModel, status);
                    },
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
          ],
        );
      },
    );
  }

  // Obtener estados disponibles según el estado actual
  List<ServiceStatus> _getAvailableStatuses(ServiceStatus currentStatus) {
    switch (currentStatus) {
      case ServiceStatus.offered:
        return [ServiceStatus.accepted];
      case ServiceStatus.accepted:
        return [ServiceStatus.inProgress];
      case ServiceStatus.inProgress:
        return [ServiceStatus.completed];
      case ServiceStatus.completed:
        return [ServiceStatus.rated];
      // Para otros estados, puedes definir transiciones adicionales si es necesario
      default:
        return [];
    }
  }

  // Método para cambiar estado directamente
  void _changeServiceStatus(
    BuildContext context,
    ServiceStatusViewModel viewModel,
    ServiceStatus newStatus,
  ) async {
    print("Changing service status to: $newStatus");
    bool success = false;
    String message = '';

    try {
      if (newStatus == ServiceStatus.inProgress) {
        print("Starting service...");
        final result = await viewModel.startService();
        success = result.isSuccess;
        message =
            success
                ? 'Estado cambiado a En Progreso'
                : result.error ?? 'Error al iniciar el trabajo';
      } else if (newStatus == ServiceStatus.completed) {
        print("Completing service...");
        final result = await viewModel.completeService();
        success = result.isSuccess;
        message =
            success
                ? 'Se ha enviado solicitud de confirmación al cliente'
                : result.error ?? 'Error al completar el trabajo';
      } else if (newStatus == ServiceStatus.accepted) {
        // Simulamos aceptación del cliente
        success = true;
        message = 'Estado cambiado a Aceptado';
        // Aquí deberías implementar la lógica real para aceptar el servicio
      } else if (newStatus == ServiceStatus.rated) {
        // Simulamos que se ha calificado el servicio
        success = true;
        message = 'Estado cambiado a Finalizado';
        // Aquí deberías implementar la lógica real para calificar el servicio
      }
    } catch (e) {
      success = false;
      message = e.toString();
      print("Error changing service status: $e");
    }

    print("Service status change result: success=$success, message=$message");

    // Mostrar resultado como SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
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
