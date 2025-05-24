import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service_request_model.dart';
import '../../view_models/category_view_model.dart';
import '../../view_models/service_request_view_model.dart';
import 'components/service_detail_header.dart';
import 'components/service_detail_info.dart';
import 'components/service_detail_photos.dart';
import 'components/service_detail_proposals.dart';
import 'components/service_detail_actions.dart';

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

      // También cargar categorías si no están cargadas
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );
      if (categoryViewModel.categories.isEmpty) {
        categoryViewModel.loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles de Solicitud'), elevation: 0),
      body: Consumer<ServiceRequestViewModel>(
        builder: (context, requestViewModel, child) {
          if (requestViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestViewModel.hasError) {
            return _buildErrorView(requestViewModel.errorMessage);
          }

          if (requestViewModel.currentRequest == null) {
            return _buildNotFoundView();
          }

          return _buildRequestDetail(context, requestViewModel.currentRequest!);
        },
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar la solicitud',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Solicitud no encontrada',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La solicitud que buscas no existe o fue eliminada',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
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
          // Header con estado y fecha
          ServiceDetailHeader(request: request),

          const SizedBox(height: 16),

          // Información principal
          ServiceDetailInfo(request: request),

          const SizedBox(height: 16),

          // Fotos si las hay
          if (request.photos != null && request.photos!.isNotEmpty) ...[
            ServiceDetailPhotos(photos: request.photos!),
            const SizedBox(height: 16),
          ],

          // Propuestas de técnicos
          ServiceDetailProposals(request: request),

          const SizedBox(height: 24),

          // Acciones (editar, cancelar, etc.)
          ServiceDetailActions(request: request),

          const SizedBox(height: 32), // Espacio adicional al final
        ],
      ),
    );
  }
}
