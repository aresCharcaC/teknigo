// lib/presentation/screens/chat/components/service_status_card.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/service_enums.dart';
import '../../../../core/models/service_model.dart';
import '../../../view_models/service_status_view_model.dart';
import 'price_confirmation_dialog.dart';

class ServiceStatusCard extends StatelessWidget {
  final String chatId;

  const ServiceStatusCard({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceStatusViewModel>(
      builder: (context, viewModel, child) {
        // Si está cargando y no hay servicio, mostrar indicador
        if (viewModel.isLoading && viewModel.currentService == null) {
          print('ServiceStatusCard: Cargando...');
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

        // Si no hay servicio asociado a este chat todavía o hay error
        if (viewModel.currentService == null) {
          print('ServiceStatusCard: No hay servicio');
          if (viewModel.hasError) {
            print('ServiceStatusCard: Error: ${viewModel.errorMessage}');
          }

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
                    'Chat de servicio',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          );
        }

        // Si hay servicio, mostrar tarjeta completa
        final service = viewModel.currentService!;
        print(
          'ServiceStatusCard: Mostrando servicio: ${service.id}, estado: ${service.status}',
        );

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

              // Mostrar roles para depuración
              if (false) // Cambiar a true para depuración
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Debug: isClient=${viewModel.isClient}, isTechnician=${viewModel.isTechnician}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

              // Detalles del servicio o mensaje según estado
              _buildServiceDetails(context, service),

              // Botones de acción según el estado y rol
              _buildActionButtons(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  // Construir detalles del servicio según estado
  Widget _buildServiceDetails(BuildContext context, ServiceModel service) {
    // Mensajes según estado
    String statusMessage = '';

    switch (service.status) {
      case ServiceStatus.offered:
        statusMessage =
            'El técnico te ha enviado una propuesta para este servicio.';
        break;
      case ServiceStatus.accepted:
        statusMessage =
            'Has aceptado esta propuesta. El técnico pronto iniciará el trabajo.';
        break;
      case ServiceStatus.inProgress:
        statusMessage =
            'El técnico está realizando el trabajo en este momento.';
        break;
      case ServiceStatus.completed:
        statusMessage = 'El técnico ha marcado este servicio como completado.';
        break;
      case ServiceStatus.rated:
        statusMessage = 'Este servicio ha sido completado y calificado.';
        break;
      default:
        return SizedBox.shrink(); // No mostrar mensaje para otros estados
    }

    // Mostrar el mensaje si hay
    if (statusMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          statusMessage,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      );
    }

    return SizedBox.shrink();
  }

  // Método para construir botones de acción según estado y rol
  Widget _buildActionButtons(
    BuildContext context,
    ServiceStatusViewModel viewModel,
  ) {
    final service = viewModel.currentService!;

    // Si no es cliente ni técnico, no mostrar botones
    if (!viewModel.isClient && !viewModel.isTechnician) {
      return const SizedBox.shrink();
    }

    // Para cliente cuando recibe una propuesta (offered)
    if (viewModel.isClient && service.status == ServiceStatus.offered) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Aquí iría la lógica para rechazar la propuesta
                  // (no implementada en esta fase)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Función no disponible por el momento'),
                    ),
                  );
                },
                child: Text('Rechazar'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Mostrar diálogo para confirmar precio
                  _showPriceConfirmation(
                    context,
                    viewModel,
                    service.price ?? 0,
                  );
                },
                child: Text('Aceptar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Para técnico cuando el servicio está aceptado pero no iniciado
    if (viewModel.isTechnician && service.status == ServiceStatus.accepted) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await viewModel.startService();
              if (result.isError && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result.error!)));
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
    }

    // Para técnico cuando el servicio está en progreso
    if (viewModel.isTechnician && service.status == ServiceStatus.inProgress) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
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
    }

    // Para cliente cuando el técnico marcó como completado
    if (viewModel.isClient && service.status == ServiceStatus.completed) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Mostrar diálogo de confirmación
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Confirmar servicio'),
                      content: Text(
                        '¿El técnico ha completado el trabajo satisfactoriamente?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('NO, AÚN NO'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Luego implementaremos la calificación aquí
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Servicio confirmado como completado',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Text('SÍ, CONFIRMAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.thumb_up),
            label: const Text('Confirmar completado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Mostrar diálogo para confirmar precio
  void _showPriceConfirmation(
    BuildContext context,
    ServiceStatusViewModel viewModel,
    double proposedPrice,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => PriceConfirmationDialog(
            proposedPrice: proposedPrice,
            onConfirm: (agreedPrice) async {
              final result = await viewModel.acceptService(agreedPrice);

              if (context.mounted) {
                if (result.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Propuesta aceptada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.error ?? 'Error al aceptar la propuesta',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
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
