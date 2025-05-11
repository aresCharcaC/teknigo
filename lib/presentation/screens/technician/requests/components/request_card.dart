// lib/presentation/screens/technician/requests/components/request_card.dart
import 'package:flutter/material.dart';
import '../../../../../core/models/service_request_model.dart';
import '../../../../../core/constants/app_colors.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback onTap;
  final VoidCallback onIgnore;

  const RequestCard({
    Key? key,
    required this.request,
    required this.onTap,
    required this.onIgnore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: título y urgencia
              Row(
                children: [
                  // Indicador de urgencia si es necesario
                  if (request.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            color: Colors.red,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'URGENTE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Título de la solicitud
                  Expanded(
                    child: Text(
                      request.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Botón de "No me interesa"
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: Colors.grey),
                    tooltip: 'No me interesa',
                    onPressed: () {
                      // Mostrar diálogo de confirmación
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text('¿No te interesa esta solicitud?'),
                              content: Text(
                                'Esta solicitud no volverá a aparecer en tu lista.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('CANCELAR'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onIgnore();
                                  },
                                  child: Text(
                                    'NO ME INTERESA',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Descripción corta
              Text(
                request.description,
                style: TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12),

              // Fila inferior: categoría, ubicación y tiempo
              Row(
                children: [
                  // Icono y tipo de servicio
                  Icon(
                    request.inClientLocation ? Icons.home : Icons.business,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  SizedBox(width: 4),
                  Text(
                    request.inClientLocation ? 'A domicilio' : 'En local',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),

                  SizedBox(width: 12),

                  // Categoría (primera categoría)
                  if (request.categoryIds.isNotEmpty)
                    Expanded(
                      child: Text(
                        _getCategoryName(request.categoryIds.first),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Fecha de publicación
                  Text(
                    _getTimeAgo(request.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    // Mapa de categorías (podrías moverlo a un servicio o constante)
    final Map<String, String> categories = {
      '1': 'Electricista',
      '2': 'Iluminación',
      '3': 'Plomero',
      '4': 'Calefacción',
      '5': 'Técnico PC',
      '6': 'Reparador de Móviles',
      '7': 'Redes',
      '8': 'Refrigeración',
      '9': 'Ventilación',
      '10': 'Cerrajero',
      '11': 'Alarmas',
      '12': 'Carpintero',
      '13': 'Ebanista',
      '14': 'Albañil',
      '15': 'Yesero',
      '16': 'Pintor',
      '17': 'Jardinero',
      '18': 'Otros',
    };

    return categories[categoryId] ?? 'Categoría';
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'hace un momento';
    }
  }
}
