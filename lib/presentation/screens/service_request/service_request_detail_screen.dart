import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service_request_model.dart';
import '../../view_models/category_view_model.dart';
import '../../view_models/service_request_view_model.dart';

class ServiceRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const ServiceRequestDetailScreen({Key? key, required this.requestId})
    : super(key: key);

  @override
  _ServiceRequestDetailScreenState createState() =>
      _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState
    extends State<ServiceRequestDetailScreen> {
  @override
  void initState() {
    super.initState();

    // Load the service request details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );
      requestViewModel.getServiceRequestById(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles de Solicitud')),
      body: Consumer<ServiceRequestViewModel>(
        builder: (context, requestViewModel, child) {
          if (requestViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestViewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${requestViewModel.errorMessage}',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          if (requestViewModel.currentRequest == null) {
            return const Center(child: Text('No se encontró la solicitud'));
          }

          return _buildRequestDetail(context, requestViewModel.currentRequest!);
        },
      ),
    );
  }

  Widget _buildRequestDetail(
    BuildContext context,
    ServiceRequestModel request,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Status and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(request.status),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getStatusText(request.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatDateTime(request.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title and description
                  Text(
                    request.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    request.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Details card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // Categories
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.category,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Categorías:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer<CategoryViewModel>(
                          builder: (context, categoryViewModel, child) {
                            final categoryNames = request.categoryIds
                                .map((id) {
                                  final category = categoryViewModel.categories
                                      .firstWhere((c) => c.id == id);

                                  return category?.name ?? 'Categoría';
                                })
                                .join(', ');

                            return Text(
                              categoryNames.isNotEmpty
                                  ? categoryNames
                                  : 'No especificadas',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Urgency
                  Row(
                    children: [
                      Icon(Icons.timer, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'Urgencia:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        request.isUrgent ? 'Urgente (para hoy)' : 'Normal',
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              request.isUrgent
                                  ? Colors.red
                                  : Colors.grey.shade800,
                          fontWeight:
                              request.isUrgent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        request.inClientLocation ? Icons.home : Icons.store,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ubicación:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.inClientLocation
                                  ? 'En tu ubicación'
                                  : 'En local del técnico',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            if (request.inClientLocation &&
                                request.address != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                request.address!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (request.scheduledDate != null) ...[
                    const SizedBox(height: 12),

                    // Scheduled date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Fecha programada:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(request.scheduledDate!),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Photos (if any)
          if (request.photos != null && request.photos!.isNotEmpty) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fotos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: request.photos!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                request.photos![index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],

          // Proposals section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Propuestas de técnicos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (request.proposalCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${request.proposalCount}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (request.proposalCount == 0) ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Esperando propuestas de técnicos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los técnicos disponibles en tu ciudad verán tu solicitud y te enviarán propuestas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Mock proposals
                    _buildMockProposals(context, request),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Only show cancel button if status is pending
          if (request.status == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmCancel(context, request.id),
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text('CANCELAR SOLICITUD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Mock proposals for testing
  Widget _buildMockProposals(
    BuildContext context,
    ServiceRequestModel request,
  ) {
    final mockProposals = [
      {
        'techId': 'tech1',
        'name': 'Carlos López',
        'rating': 4.8,
        'image': 'https://randomuser.me/api/portraits/men/32.jpg',
        'price': 80.0,
        'message':
            'Puedo ayudarte con tu problema. Tengo experiencia en este tipo de reparaciones.',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'techId': 'tech2',
        'name': 'María García',
        'rating': 4.5,
        'image': 'https://randomuser.me/api/portraits/women/44.jpg',
        'price': 75.0,
        'message':
            'Hola, tengo disponibilidad para atender tu solicitud. Puedo ir hoy mismo si es urgente.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockProposals.length,
      itemBuilder: (context, index) {
        final proposal = mockProposals[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Technician info and price
                Row(
                  children: [
                    // Profile image
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        proposal['image'] as String,
                      ),
                      onBackgroundImageError:
                          (e, s) => const Icon(Icons.person),
                    ),

                    const SizedBox(width: 12),

                    // Name and rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proposal['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${proposal['rating']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'S/ ${proposal['price']}',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  proposal['message'] as String,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),

                const SizedBox(height: 12),

                // Time and buttons
                Row(
                  children: [
                    Text(
                      _formatTime(proposal['time'] as DateTime),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const Spacer(),

                    // Only show action buttons if request is pending
                    if (request.status == 'pending') ...[
                      // Message button
                      OutlinedButton.icon(
                        onPressed:
                            () => _contactTechnician(
                              proposal['techId'] as String,
                            ),
                        icon: const Icon(Icons.message),
                        label: const Text('Contactar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Accept button
                      ElevatedButton.icon(
                        onPressed:
                            () => _acceptProposal(proposal['techId'] as String),
                        icon: const Icon(Icons.check),
                        label: const Text('Aceptar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Contact a technician
  void _contactTechnician(String techId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contactando al técnico $techId...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // TODO: Implement chat functionality
  }

  // Accept a proposal
  void _acceptProposal(String techId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Aceptar propuesta'),
            content: const Text(
              '¿Estás seguro de que deseas aceptar esta propuesta? '
              'El técnico se pondrá en contacto contigo para coordinar el servicio.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement accepting proposal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Propuesta aceptada correctamente'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('ACEPTAR'),
              ),
            ],
          ),
    );
  }

  // Confirm cancellation of request
  void _confirmCancel(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar solicitud'),
            content: const Text(
              '¿Estás seguro de que deseas cancelar esta solicitud?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('NO'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelRequest(requestId);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('SÍ, CANCELAR'),
              ),
            ],
          ),
    );
  }

  // Cancel the request
  Future<void> _cancelRequest(String requestId) async {
    try {
      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );

      await requestViewModel.deleteServiceRequest(requestId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud cancelada correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Go back to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar la solicitud: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper methods for UI elements
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'accepted':
        return 'ACEPTADO';
      case 'completed':
        return 'COMPLETADO';
      case 'cancelled':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }
}
