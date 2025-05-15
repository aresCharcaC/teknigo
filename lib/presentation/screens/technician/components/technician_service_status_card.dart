// lib/presentation/screens/technician/components/technician_service_status_card.dart
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
    print('Building TechnicianServiceStatusCard for chatId: $chatId');

    return Consumer<ServiceStatusViewModel>(
      builder: (context, viewModel, child) {
        // Log para debugging
        print(
          'TechnicianServiceStatusCard - BuildContext hash: ${context.hashCode}',
        );
        print('TechnicianServiceStatusCard - ViewModel: ${viewModel.hashCode}');
        print(
          'TechnicianServiceStatusCard - Service: ${viewModel.currentService?.id}',
        );
        print(
          'TechnicianServiceStatusCard - isTechnician: ${viewModel.isTechnician}',
        );
        print(
          'TechnicianServiceStatusCard - Service Status: ${viewModel.currentService?.status}',
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

        // Si hay servicio, mostrar tarjeta completa
        final service = viewModel.currentService!;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Título y estado
              Row(
                children: [
                  Icon(
                    _getStatusIcon(service.status),
                    color: _getStatusColor(service.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(service.status),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(service.status),
                    ),
                  ),
                  const Spacer(),
                  if (service.agreedPrice != null)
                    Text(
                      'Precio: S/ ${service.agreedPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),

              // Detalles del servicio o mensaje según estado
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _getTechnicianStatusMessage(service.status),
              ),

              // Botones de acción según el estado (específicos para técnicos)
              _buildTechnicianActionButtons(context, viewModel, service),
            ],
          ),
        );
      },
    );
  }

  // Construir botones específicos para técnicos
  Widget _buildTechnicianActionButtons(
    BuildContext context,
    ServiceStatusViewModel viewModel,
    ServiceModel service,
  ) {
    // Primero verificamos que sea técnico
    if (!viewModel.isTechnician) {
      return SizedBox.shrink();
    }

    // Ahora dependiendo del estado, mostramos botones específicos
    switch (service.status) {
      case ServiceStatus.accepted:
        // Para servicio aceptado: botón para iniciar trabajo
        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                print('Botón Iniciar trabajo presionado');
                final result = await viewModel.startService();
                if (result.isError && context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result.error!)));
                } else if (result.isSuccess && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Servicio iniciado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar trabajo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        );

      case ServiceStatus.inProgress:
        // Para servicio en progreso: botón para marcar como completado
        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                print('Botón Marcar como completado presionado');
                // Pedir confirmación
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Confirmar finalización'),
                        content: Text(
                          '¿Has completado el trabajo? El cliente será notificado para que confirme.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('CANCELAR'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('CONFIRMAR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                );

                if (confirmed == true) {
                  final result = await viewModel.completeService();
                  if (result.isError && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result.error!)));
                  } else if (result.isSuccess && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Servicio marcado como completado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Marcar como completado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }

  // Obtener mensaje específico para técnicos según el estado
  Widget _getTechnicianStatusMessage(ServiceStatus status) {
    String message = '';

    switch (status) {
      case ServiceStatus.offered:
        message = 'Has enviado una propuesta. Esperando respuesta del cliente.';
        break;
      case ServiceStatus.accepted:
        message = 'El cliente aceptó tu propuesta. Puedes iniciar el trabajo.';
        break;
      case ServiceStatus.inProgress:
        message =
            'Estás realizando el servicio. Al finalizar, márcalo como completado.';
        break;
      case ServiceStatus.completed:
        message =
            'Has marcado el servicio como completado. Esperando confirmación del cliente.';
        break;
      case ServiceStatus.rated:
        message = 'Servicio completado y calificado. ¡Gracias por tu trabajo!';
        break;
      default:
        message = 'Estado actual del servicio: ${_getStatusText(status)}';
    }

    return Text(
      message,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
        return 'Pendiente';
      case ServiceStatus.offered:
        return 'Propuesta enviada';
      case ServiceStatus.accepted:
        return 'Servicio aceptado';
      case ServiceStatus.inProgress:
        return 'Trabajo en progreso';
      case ServiceStatus.completed:
        return 'Trabajo completado';
      case ServiceStatus.rated:
        return 'Servicio finalizado';
      case ServiceStatus.cancelled:
        return 'Servicio cancelado';
      case ServiceStatus.rejected:
        return 'Propuesta rechazada';
      default:
        return 'Estado desconocido';
    }
  }
}
