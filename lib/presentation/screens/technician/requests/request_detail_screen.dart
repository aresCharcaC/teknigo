// lib/presentation/screens/technician/requests/request_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/technician_requests_view_model.dart';
import '../../../view_models/service_proposal_view_model.dart';
import '../components/proposal_form_dialog.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({Key? key, required this.requestId})
    : super(key: key);

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los detalles de la solicitud
    Future.microtask(() {
      Provider.of<TechnicianRequestsViewModel>(
        context,
        listen: false,
      ).loadRequestDetails(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Solicitud'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TechnicianRequestsViewModel>(
                context,
                listen: false,
              ).loadRequestDetails(widget.requestId);
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Consumer<TechnicianRequestsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => viewModel.loadRequestDetails(widget.requestId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.selectedRequest == null) {
            return const Center(child: Text('Solicitud no encontrada'));
          }

          final request = viewModel.selectedRequest!;
          return _buildRequestDetails(context, request, viewModel);
        },
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  Widget _buildRequestDetails(
    BuildContext context,
    ServiceRequestModel request,
    TechnicianRequestsViewModel viewModel,
  ) {
    // Formatear fechas
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');
    final createdDate = dateFormat.format(request.createdAt);
    final scheduledDate =
        request.scheduledDate != null
            ? dateFormat.format(request.scheduledDate!)
            : 'No programada';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y estado
          _buildHeader(context, request),

          const SizedBox(height: 24),

          // Chips informativos (urgente, a domicilio, etc.)
          _buildInfoChips(context, request),

          const SizedBox(height: 24),

          // Información de la solicitud
          _buildSectionTitle(context, 'Descripción'),
          const SizedBox(height: 8),
          Text(request.description, style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 24),

          // Fechas
          _buildSectionTitle(context, 'Fechas'),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Fecha de solicitud:',
            createdDate,
            Icons.calendar_today,
          ),
          if (request.scheduledDate != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Fecha programada:',
              scheduledDate,
              Icons.event,
            ),
          ],

          const SizedBox(height: 24),

          // Ubicación
          _buildSectionTitle(context, 'Ubicación'),
          const SizedBox(height: 8),
          if (request.address != null && request.address!.isNotEmpty)
            _buildInfoRow(
              context,
              'Dirección:',
              request.address!,
              Icons.location_on,
            ),

          if (request.location != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: request.location!,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('requestLocation'),
                      position: request.location!,
                      infoWindow: InfoWindow(title: request.title),
                    ),
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                ),
              ),
            ),
          ],

          // Fotos de la solicitud (si existen)
          if (request.photos != null && request.photos!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Fotos'),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: request.photos!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        // Mostrar la imagen a pantalla completa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Foto de solicitud'),
                                  ),
                                  body: Center(
                                    child: InteractiveViewer(
                                      child: Image.network(
                                        request.photos![index],
                                        fit: BoxFit.contain,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          request.photos![index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Espacio para los botones inferiores
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ServiceRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                request.isUrgent
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            request.isUrgent ? 'URGENTE' : 'SOLICITUD',
            style: TextStyle(
              color: request.isUrgent ? Colors.red : Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Título
        Text(
          request.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoChips(BuildContext context, ServiceRequestModel request) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Chip de tipo de servicio
        Chip(
          avatar: Icon(
            request.inClientLocation ? Icons.home_work : Icons.business_center,
            size: 18,
            color: Colors.blue,
          ),
          label: Text(
            request.inClientLocation ? 'A domicilio' : 'En local del técnico',
          ),
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),

        // Chip de urgencia
        if (request.isUrgent)
          const Chip(
            avatar: Icon(Icons.priority_high, size: 18, color: Colors.red),
            label: Text('Urgente'),
            backgroundColor: Color(0xFFFFEBEE), // Red 50
          ),

        // Chip de fecha programada
        if (request.scheduledDate != null)
          Chip(
            avatar: const Icon(Icons.event, size: 18, color: Colors.green),
            label: Text(
              'Programado: ${DateFormat('dd/MM/yyyy').format(request.scheduledDate!)}',
            ),
            backgroundColor: Colors.green.withOpacity(0.1),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Consumer<TechnicianRequestsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.selectedRequest == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Botón para rechazar/ignorar la solicitud
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmIgnoreRequest(context, viewModel),
                  icon: const Icon(Icons.close),
                  label: const Text('No me interesa'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Botón para enviar propuesta
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showProposalForm(context),
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar propuesta'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Confirmar ignorar solicitud
  void _confirmIgnoreRequest(
    BuildContext context,
    TechnicianRequestsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Ignorar solicitud'),
            content: const Text(
              '¿Estás seguro de que quieres ignorar esta solicitud? '
              'Ya no se mostrará en tu lista de solicitudes disponibles.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Cerrar diálogo
                  viewModel.ignoreRequest(widget.requestId).then((_) {
                    Navigator.pop(context); // Volver a pantalla anterior
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitud ignorada correctamente'),
                      ),
                    );
                  });
                },
                child: const Text(
                  'IGNORAR',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Mostrar formulario de propuesta
  void _showProposalForm(BuildContext context) {
    final proposalViewModel = Provider.of<ServiceProposalViewModel>(
      context,
      listen: false,
    );
    final requestsViewModel = Provider.of<TechnicianRequestsViewModel>(
      context,
      listen: false,
    );

    if (requestsViewModel.selectedRequest == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ProposalFormDialog(
            request: requestsViewModel.selectedRequest!,
            onSubmit: (price, description, availableDate) {
              proposalViewModel
                  .sendProposal(
                    requestId: requestsViewModel.selectedRequest!.id,
                    price: price,
                    description: description,
                    availableDate: availableDate,
                  )
                  .then((result) {
                    Navigator.pop(context); // Cerrar formulario
                    if (result.isSuccess) {
                      Navigator.pop(context); // Volver a pantalla anterior
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Propuesta enviada correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${result.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
            },
          ),
    );
  }
}
