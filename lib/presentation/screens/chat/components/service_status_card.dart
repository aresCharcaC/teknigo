// lib/presentation/screens/chat/components/service_status_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/service_enums.dart';
import '../../../../core/models/service_model.dart';
import '../../../view_models/service_status_view_model.dart';
import 'price_confirmation_dialog.dart';
import 'service_rating_dialog.dart';

class ServiceStatusCard extends StatelessWidget {
  final String chatId;

  const ServiceStatusCard({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceStatusViewModel>(
      builder: (context, viewModel, child) {
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

        // Si no hay servicio asociado a este chat todavía o hay error
        if (viewModel.currentService == null) {
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

        return Column(
          children: [
            // Tarjeta de estado
            Container(
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

                  // Detalles del servicio según estado
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _getStatusMessage(service.status, viewModel.isClient),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sección de botones de acción según el estado y rol del usuario
            if (_shouldShowActionButtons(service.status, viewModel))
              _buildActionButtonsSection(context, service, viewModel),
          ],
        );
      },
    );
  }

  // Determinar si se deben mostrar botones de acción
  bool _shouldShowActionButtons(
    ServiceStatus status,
    ServiceStatusViewModel viewModel,
  ) {
    // Mostrar botones para técnico en estos estados
    if (viewModel.isTechnician) {
      return status == ServiceStatus.accepted ||
          status == ServiceStatus.inProgress;
    }

    // Mostrar botones para cliente en estos estados
    if (viewModel.isClient) {
      return status == ServiceStatus.offered ||
          status == ServiceStatus.completed;
    }

    return false;
  }

  // Sección dedicada para botones de acción con estilo destacado
  Widget _buildActionButtonsSection(
    BuildContext context,
    ServiceModel service,
    ServiceStatusViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones disponibles:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          _buildActionButtons(context, service, viewModel),
        ],
      ),
    );
  }

  // Botones de acción según estado y rol
  Widget _buildActionButtons(
    BuildContext context,
    ServiceModel service,
    ServiceStatusViewModel viewModel,
  ) {
    // Para cliente cuando recibe una propuesta (offered)
    if (viewModel.isClient && service.status == ServiceStatus.offered) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Lógica para rechazar la propuesta (no implementada en esta fase)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Función no disponible por el momento'),
                  ),
                );
              },
              icon: Icon(Icons.cancel, color: Colors.red),
              label: Text('Rechazar propuesta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Mostrar diálogo para confirmar precio
                _showPriceConfirmation(context, viewModel, service.price ?? 0);
              },
              icon: Icon(Icons.check_circle),
              label: Text('Aceptar propuesta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    // Para técnico cuando el servicio está aceptado pero no iniciado
    if (viewModel.isTechnician && service.status == ServiceStatus.accepted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
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
          icon: const Icon(Icons.play_arrow, size: 24),
          label: const Text('INICIAR TRABAJO', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );
    }

    // Para técnico cuando el servicio está en progreso
    if (viewModel.isTechnician && service.status == ServiceStatus.inProgress) {
      return SizedBox(
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
          icon: const Icon(Icons.check_circle, size: 24),
          label: const Text(
            'MARCAR COMO COMPLETADO',
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );
    }

    // Para cliente cuando el técnico marcó como completado
    if (viewModel.isClient && service.status == ServiceStatus.completed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Mostrar diálogo de calificación
            showDialog(
              context: context,
              builder:
                  (context) => ServiceRatingDialog(
                    onSubmit: (rating, comment) async {
                      Navigator.pop(context);

                      // Llamar a método para calificar servicio
                      final result = await viewModel.rateService(
                        rating,
                        comment,
                      );

                      if (context.mounted) {
                        if (result.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Servicio calificado correctamente',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result.error ?? 'Error al calificar servicio',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
            );
          },
          icon: const Icon(Icons.star, size: 24),
          label: const Text(
            'CONFIRMAR Y CALIFICAR',
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
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

  // Mensaje según estado
  String _getStatusMessage(ServiceStatus status, bool isClient) {
    if (isClient) {
      // Mensajes para cliente
      switch (status) {
        case ServiceStatus.offered:
          return 'El técnico te ha enviado una propuesta para este servicio.';
        case ServiceStatus.accepted:
          return 'Has aceptado esta propuesta. El técnico pronto iniciará el trabajo.';
        case ServiceStatus.inProgress:
          return 'El técnico está realizando el trabajo en este momento.';
        case ServiceStatus.completed:
          return 'El técnico ha marcado este servicio como completado. Por favor confirma y califica.';
        case ServiceStatus.rated:
          return 'Este servicio ha sido completado y calificado satisfactoriamente.';
        default:
          return 'Servicio en estado pendiente.';
      }
    } else {
      // Mensajes para técnico
      switch (status) {
        case ServiceStatus.offered:
          return 'Has enviado una propuesta para este servicio. Esperando respuesta del cliente.';
        case ServiceStatus.accepted:
          return 'El cliente ha aceptado tu propuesta. Puedes iniciar el trabajo cuando estés listo.';
        case ServiceStatus.inProgress:
          return 'Has iniciado este servicio. Cuando termines, márcalo como completado.';
        case ServiceStatus.completed:
          return 'Has marcado este servicio como completado. Esperando confirmación del cliente.';
        case ServiceStatus.rated:
          return 'El cliente ha calificado este servicio como completado.';
        default:
          return 'Servicio en estado pendiente.';
      }
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
    }
  }
}
