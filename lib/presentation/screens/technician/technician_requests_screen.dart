// lib/presentation/screens/technician/technician_requests_screen.dart
import 'package:flutter/material.dart';

class TechnicianRequestsScreen extends StatefulWidget {
  const TechnicianRequestsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianRequestsScreenState createState() =>
      _TechnicianRequestsScreenState();
}

class _TechnicianRequestsScreenState extends State<TechnicianRequestsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;

  // Listas de solicitudes (datos simulados)
  final List<ServiceRequest> _pendingRequests = [
    ServiceRequest(
      id: '1',
      clientName: 'María González',
      category: 'Electricista',
      description:
          'No funciona la luz en la cocina, necesito que la reparen urgente.',
      location: 'Av. Arequipa 456, Arequipa',
      distance: 2.3,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      budget: 120,
      isUrgent: true,
    ),
    ServiceRequest(
      id: '2',
      clientName: 'Pedro Ramírez',
      category: 'Electricista',
      description: 'Necesito instalar lámparas en mi sala, son 3 en total.',
      location: 'Calle Melgar 234, Arequipa',
      distance: 4.1,
      createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
      budget: 80,
      isUrgent: false,
    ),
  ];

  final List<ServiceRequest> _acceptedRequests = [
    ServiceRequest(
      id: '3',
      clientName: 'Juan Pérez',
      category: 'Técnico PC',
      description:
          'Mi computadora se reinicia constantemente, necesito un diagnóstico y reparación.',
      location: 'Urb. Los Ángeles, Calle 5, Arequipa',
      distance: 3.5,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      budget: 150,
      isUrgent: false,
      acceptedAt: DateTime.now().subtract(const Duration(hours: 2)),
      scheduledDate: DateTime.now().add(const Duration(days: 1, hours: 15)),
    ),
  ];

  final List<ServiceRequest> _completedRequests = [
    ServiceRequest(
      id: '4',
      clientName: 'Ana Suárez',
      category: 'Electricista',
      description: 'Cortocircuito en el dormitorio, reparado exitosamente.',
      location: 'Av. Kennedy 789, Arequipa',
      distance: 1.8,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      budget: 100,
      isUrgent: true,
      acceptedAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      rating: 5.0,
      review: 'Excelente servicio, muy profesional y puntual.',
    ),
    ServiceRequest(
      id: '5',
      clientName: 'Roberto Gómez',
      category: 'Técnico PC',
      description:
          'Formateo e instalación de Windows, actualización de drivers.',
      location: 'Urb. Santa María, Arequipa',
      distance: 5.3,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      budget: 120,
      isUrgent: false,
      acceptedAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 3)),
      rating: 4.5,
      review: 'Buen trabajo, recomendado.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Aceptar una solicitud
  void _acceptRequest(ServiceRequest request) {
    setState(() {
      _pendingRequests.remove(request);
      // Actualizar la solicitud con la fecha de aceptación
      final updatedRequest = ServiceRequest(
        id: request.id,
        clientName: request.clientName,
        category: request.category,
        description: request.description,
        location: request.location,
        distance: request.distance,
        createdAt: request.createdAt,
        budget: request.budget,
        isUrgent: request.isUrgent,
        acceptedAt: DateTime.now(),
        // Programar para mañana por defecto
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
      );
      _acceptedRequests.add(updatedRequest);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Has aceptado la solicitud de ${request.clientName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Rechazar una solicitud
  void _rejectRequest(ServiceRequest request) {
    setState(() {
      _pendingRequests.remove(request);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Has rechazado la solicitud de ${request.clientName}'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // Marcar una solicitud como completada
  void _completeRequest(ServiceRequest request) {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Completar servicio'),
            content: const Text(
              '¿Estás seguro de marcar este servicio como completado?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _acceptedRequests.remove(request);
                    // Actualizar la solicitud con la fecha de finalización
                    final updatedRequest = ServiceRequest(
                      id: request.id,
                      clientName: request.clientName,
                      category: request.category,
                      description: request.description,
                      location: request.location,
                      distance: request.distance,
                      createdAt: request.createdAt,
                      budget: request.budget,
                      isUrgent: request.isUrgent,
                      acceptedAt: request.acceptedAt,
                      scheduledDate: request.scheduledDate,
                      completedAt: DateTime.now(),
                    );
                    _completedRequests.add(updatedRequest);
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Servicio marcado como completado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('COMPLETAR'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Tabs
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Aceptados'),
            Tab(text: 'Completados'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),

        // Contenido del tab
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab de solicitudes pendientes
              _buildPendingRequestsList(),

              // Tab de solicitudes aceptadas
              _buildAcceptedRequestsList(),

              // Tab de solicitudes completadas
              _buildCompletedRequestsList(),
            ],
          ),
        ),
      ],
    );
  }

  // Lista de solicitudes pendientes
  Widget _buildPendingRequestsList() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox,
        title: 'No hay solicitudes pendientes',
        subtitle: 'Las solicitudes nuevas aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _buildRequestCard(
          request: request,
          isPending: true,
          isAccepted: false,
          isCompleted: false,
        );
      },
    );
  }

  // Lista de solicitudes aceptadas
  Widget _buildAcceptedRequestsList() {
    if (_acceptedRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.handshake,
        title: 'No hay servicios en curso',
        subtitle: 'Los servicios que aceptes aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _acceptedRequests.length,
      itemBuilder: (context, index) {
        final request = _acceptedRequests[index];
        return _buildRequestCard(
          request: request,
          isPending: false,
          isAccepted: true,
          isCompleted: false,
        );
      },
    );
  }

  // Lista de solicitudes completadas
  Widget _buildCompletedRequestsList() {
    if (_completedRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: 'No hay servicios completados',
        subtitle: 'Los servicios finalizados aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedRequests.length,
      itemBuilder: (context, index) {
        final request = _completedRequests[index];
        return _buildRequestCard(
          request: request,
          isPending: false,
          isAccepted: false,
          isCompleted: true,
        );
      },
    );
  }

  // Construir estado vacío
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Construir tarjeta de solicitud
  Widget _buildRequestCard({
    required ServiceRequest request,
    required bool isPending,
    required bool isAccepted,
    required bool isCompleted,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar del cliente
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    request.clientName.isNotEmpty
                        ? request.clientName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Información del cliente y servicio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.clientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        request.category,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Presupuesto: S/ ${request.budget.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Etiqueta de urgencia o valoración
                if (isPending && request.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'URGENTE',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (isCompleted && request.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 2),
                      Text(
                        '${request.rating}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),

            // Descripción
            const Text(
              'Descripción:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(request.description),

            const SizedBox(height: 12),

            // Ubicación
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.location,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${request.distance.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información adicional basada en el estado
            if (isPending)
              Text(
                'Solicitado: ${_formatTimestamp(request.createdAt)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              )
            else if (isAccepted && request.scheduledDate != null)
              Text(
                'Programado para: ${_formatDate(request.scheduledDate!)}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              )
            else if (isCompleted && request.completedAt != null)
              Text(
                'Completado: ${_formatDate(request.completedAt!)}',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
              ),

            // Reseña (solo para completados)
            if (isCompleted &&
                request.review != null &&
                request.review!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Reseña:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                request.review!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade800,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Botones de acción
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              )
            else if (isAccepted)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navegar a chat con cliente
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente: Chat con cliente'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Contactar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeRequest(request),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Completar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              )
            else if (isCompleted)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Ver detalles del servicio completado
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente: Detalles del servicio'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Ver detalles'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Formatear fecha y hora
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace unos segundos';
    }
  }

  // Formatear fecha
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final isToday =
        date.day == now.day && date.month == now.month && date.year == now.year;
    final isTomorrow =
        date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year;

    String dateStr;
    if (isToday) {
      dateStr = 'Hoy';
    } else if (isTomorrow) {
      dateStr = 'Mañana';
    } else {
      // Formato día/mes/año
      dateStr = '${date.day}/${date.month}/${date.year}';
    }

    // Agregar hora
    return '$dateStr a las ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Clase para solicitudes de servicio
class ServiceRequest {
  final String id;
  final String clientName;
  final String category;
  final String description;
  final String location;
  final double distance;
  final DateTime createdAt;
  final double budget;
  final bool isUrgent;
  final DateTime? acceptedAt;
  final DateTime? scheduledDate;
  final DateTime? completedAt;
  final double? rating;
  final String? review;

  ServiceRequest({
    required this.id,
    required this.clientName,
    required this.category,
    required this.description,
    required this.location,
    required this.distance,
    required this.createdAt,
    required this.budget,
    required this.isUrgent,
    this.acceptedAt,
    this.scheduledDate,
    this.completedAt,
    this.rating,
    this.review,
  });
}
