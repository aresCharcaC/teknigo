// lib/presentation/screens/technician/components/status_change_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/enums/service_enums.dart';

class StatusChangeDialog extends StatelessWidget {
  final ServiceStatus currentStatus;
  final Function(ServiceStatus) onChangeStatus;

  const StatusChangeDialog({
    Key? key,
    required this.currentStatus,
    required this.onChangeStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cambiar estado del servicio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Only show status options that make sense based on current status
            ...getAvailableStatusOptions()
                .map(
                  (status) => ListTile(
                    leading: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                    ),
                    title: Text(_getStatusText(status)),
                    onTap: () {
                      onChangeStatus(status);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),

            SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCELAR'),
            ),
          ],
        ),
      ),
    );
  }

  // Get available status options based on current status
  List<ServiceStatus> getAvailableStatusOptions() {
    switch (currentStatus) {
      case ServiceStatus.offered:
        return []; // Technician should wait for client acceptance
      case ServiceStatus.accepted:
        return [ServiceStatus.inProgress]; // Can start working
      case ServiceStatus.inProgress:
        return [ServiceStatus.completed]; // Can mark as completed
      case ServiceStatus.completed:
        return []; // Waiting for client confirmation
      default:
        return []; // No changes possible
    }
  }

  // Get color based on status
  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.inProgress:
        return Colors.orange;
      case ServiceStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get icon based on status
  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.inProgress:
        return Icons.engineering;
      case ServiceStatus.completed:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  // Get text based on status
  String _getStatusText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.inProgress:
        return 'Iniciar trabajo';
      case ServiceStatus.completed:
        return 'Marcar como completado';
      default:
        return 'Estado desconocido';
    }
  }
}
