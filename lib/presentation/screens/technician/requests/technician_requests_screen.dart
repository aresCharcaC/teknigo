// lib/presentation/screens/technician/requests/technician_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../view_models/technician_requests_view_model.dart';
import '../../../widgets/technician_request_card.dart';
import 'request_detail_screen.dart';

class TechnicianRequestsScreen extends StatefulWidget {
  const TechnicianRequestsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianRequestsScreenState createState() =>
      _TechnicianRequestsScreenState();
}

class _TechnicianRequestsScreenState extends State<TechnicianRequestsScreen> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'urgent'

  @override
  void initState() {
    super.initState();
    // Cargar solicitudes cuando se inicia la pantalla
    Future.microtask(() {
      Provider.of<TechnicianRequestsViewModel>(
        context,
        listen: false,
      ).loadAvailableRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TechnicianRequestsViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            // Barra de filtros
            _buildFilterBar(context, viewModel),

            // Lista de solicitudes
            Expanded(child: _buildRequestsList(context, viewModel)),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    TechnicianRequestsViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título y contador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solicitudes disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${viewModel.filteredRequests.length}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Chips de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'Todas',
                  'all',
                  viewModel.filterRequests,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Pendientes',
                  'pending',
                  viewModel.filterRequests,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Urgentes',
                  'urgent',
                  viewModel.filterRequests,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Cercanas',
                  'nearby',
                  viewModel.filterRequests,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String filterValue,
    Function(String) onFilterChanged,
  ) {
    final isSelected = _selectedFilter == filterValue;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filterValue;
        });
        onFilterChanged(filterValue);
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      backgroundColor: Colors.grey.shade200,
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    TechnicianRequestsViewModel viewModel,
  ) {
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
              onPressed: () => viewModel.loadAvailableRequests(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (viewModel.filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No hay solicitudes disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba cambiando los filtros o vuelve más tarde',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadAvailableRequests(),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadAvailableRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.filteredRequests.length,
        itemBuilder: (context, index) {
          final request = viewModel.filteredRequests[index];
          return TechnicianRequestCard(
            request: request,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RequestDetailScreen(requestId: request.id),
                ),
              );
            },
            onIgnore: () => viewModel.ignoreRequest(request.id),
          );
        },
      ),
    );
  }
}
