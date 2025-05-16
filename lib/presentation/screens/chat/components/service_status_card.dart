// lib/presentation/screens/chat/components/service_status_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/service_enums.dart';
import '../../../../core/models/service_model.dart';
import '../../../view_models/service_status_view_model.dart';

class ServiceStatusCard extends StatelessWidget {
  final String chatId;

  const ServiceStatusCard({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceStatusViewModel>(
      builder: (context, viewModel, child) {
        // If loading and no service, show loading indicator
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

        // If no service associated with this chat yet
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
                    'Chat de servicio',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          );
        }

        // If there is a service, show status card
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
          child: Row(
            children: [
              // Status icon
              Icon(
                _getStatusIcon(service.status),
                color: _getStatusColor(service.status),
                size: 24,
              ),
              const SizedBox(width: 8),

              // Status text
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

              // Price if available
              if (service.agreedPrice != null)
                Text(
                  'S/ ${service.agreedPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

              // NO edit button for client view
            ],
          ),
        );
      },
    );
  }

  // Get color based on status
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

  // Get icon based on status
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

  // Get text based on status
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
      case ServiceStatus.cancelled:
        return 'SERVICIO CANCELADO';
      case ServiceStatus.rejected:
        return 'PROPUESTA RECHAZADA';
      default:
        return 'ESTADO DESCONOCIDO';
    }
  }
}
