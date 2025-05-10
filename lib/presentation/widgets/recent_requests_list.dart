/*
// lib/presentation/widgets/recent_requests_list.dart
import 'package:flutter/material.dart';
import '../../core/models/service_request_model.dart';

class RecentRequestsList extends StatelessWidget {
  final List<ServiceRequestModel> requests;
  final Function(String) onTap;
  
  const RecentRequestsList({
    Key? key,
    required this.requests,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestItem(context, request);
      },
    );
  }
  
  Widget _buildRequestItem(BuildContext context, ServiceRequestModel request) {
    // Obtener color según estado
    Color statusColor;
    switch (request.status) {
      case ServiceStatus.pending:
      case ServiceStatus.offered:
        statusColor = Colors.amber;
        break;
      case ServiceStatus.accepted:
      case ServiceStatus.inProgress:
        statusColor = Colors.blue;
        break;
      case ServiceStatus.completed:
      case ServiceStatus.rated:
        statusColor = Colors.green;
        break;
      case ServiceStatus.cancelled:
      case ServiceStatus.rejected:
        statusColor = Colors.grey;
        break;
    }
    
    // Obtener texto según estado
    String statusText;
    switch (request.status) {
      case ServiceStatus.pending:
        statusText = 'Pendiente';
        break;
      case ServiceStatus.offered:
        statusText = 'Con propuestas';
        break;
      case ServiceStatus.accepted:
        statusText = 'Aceptado';
        break;
      case ServiceStatus.inProgress:
        statusText = 'En proceso';
        break;
      case ServiceStatus.completed:
        statusText = 'Completado';
        break;
      case ServiceStatus.rated:
        statusText = 'Valorado';
        break;
      case ServiceStatus.cancelled:
        statusText = 'Cancelado';
        break;
      case ServiceStatus.rejected:
        statusText = 'Rechazado';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => onTap(request.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Indicador de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Título de la solicitud
                  Expanded(
                    child: Text(
                      request.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Información adicional
              Row(
                children: [
                  // Tiempo transcurrido
                  Text(
                    _formatTimeAgo(request.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  
                  const Text(' • ', style: TextStyle(color: Colors.grey)),
                  
                  // Información según estado
                  _buildStatusInfo(request),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Construir información adicional según estado
  Widget _buildStatusInfo(ServiceRequestModel request) {
    switch (request.status) {
      case ServiceStatus.pending:
        return const Text(
          'Esperando propuestas',
          style: TextStyle(fontSize: 12),
        );
      
      case ServiceStatus.offered:
        // Contar propuestas (esto debería venir del modelo)
        final proposalCount = 2; // Ejemplo, debería ser dinámico
        return Text(
          '$proposalCount propuestas',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
      
      case ServiceStatus.accepted:
      case ServiceStatus.inProgress:
      case ServiceStatus.completed:
      case ServiceStatus.rated:
        // Mostrar nombre del técnico
        final technicianName = request.technicianId ?? 'Técnico';
        return Text(
          'Técnico: $technicianName',
          style: const TextStyle(fontSize:*/
