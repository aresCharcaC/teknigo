import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../view_models/technician_view_model.dart';
import '../../../view_models/service_request_view_model.dart';

/// Pantalla para que los técnicos gestionen las solicitudes de servicio
class TechnicianRequestsScreen extends StatefulWidget {
  const TechnicianRequestsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianRequestsScreenState createState() =>
      _TechnicianRequestsScreenState();
}

class _TechnicianRequestsScreenState extends State<TechnicianRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar solicitudes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );
      serviceViewModel.loadPendingRequests();
      serviceViewModel.loadAcceptedServices();
      serviceViewModel.loadCompletedServices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceRequestViewModel(),
      child: Consumer<ServiceRequestViewModel>(
        builder: (context, requestViewModel, _) {
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
                    _buildPendingRequestsList(requestViewModel),

                    // Tab de solicitudes aceptadas
                    _buildAcceptedRequestsList(requestViewModel),

                    // Tab de solicitudes completadas
                    _buildCompletedRequestsList(requestViewModel),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Lista de solicitudes pendientes
  Widget _buildPendingRequestsList(ServiceRequestViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.pendingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox,
        title: 'No hay solicitudes pendientes',
        subtitle: 'Las solicitudes nuevas aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.pendingRequests.length,
      itemBuilder: (context, index) {
        final request = viewModel.pendingRequests[index];
        return _buildRequestCard(
          request: request,
          isPending: true,
          isAccepted: false,
          isCompleted: false,
          onAccept: () => viewModel.acceptRequest(request.id),
          onReject: () => viewModel.rejectRequest(request.id),
          onComplete: null,
          onContact: null,
        );
      },
    );
  }

  // Lista de solicitudes aceptadas
  Widget _buildAcceptedRequestsList(ServiceRequestViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.acceptedServices.isEmpty) {
      return _buildEmptyState(
        icon: Icons.handshake,
        title: 'No hay servicios en curso',
        subtitle: 'Los servicios que aceptes aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.acceptedServices.length,
      itemBuilder: (context, index) {
        final request = viewModel.acceptedServices[index];
        return _buildRequestCard(
          request: request,
          isPending: false,
          isAccepted: true,
          isCompleted: false,
          onAccept: null,
          onReject: null,
          onComplete: () => viewModel.completeService(request.id),
          onContact: () => _contactClient(request),
        );
      },
    );
  }

  // Lista de solicitudes completadas
  Widget _buildCompletedRequestsList(ServiceRequestViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.completedServices.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: 'No hay servicios completados',
        subtitle: 'Los servicios finalizados aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.completedServices.length,
      itemBuilder: (context, index) {
        final request = viewModel.completedServices[index];
        return _buildRequestCard(
          request: request,
          isPending: false,
          isAccepted: false,
          isCompleted: true,
          onAccept: null,
          onReject: null,
          onComplete: null,
          onContact: null,
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
    VoidCallback? onAccept,
    VoidCallback? onReject,
    VoidCallback? onComplete,
    VoidCallback? onContact,
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
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
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
                      onPressed: onContact,
                      icon: const Icon(Icons.chat),
                      label: const Text('Contactar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onComplete,
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

  // Contactar al cliente
  void _contactClient(ServiceRequest request) {
    // Navegar al chat con el cliente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contactando a ${request.clientName}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navegar a la pantalla de chat (implementación pendiente)
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

/// Modelo para solicitud de servicio
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
