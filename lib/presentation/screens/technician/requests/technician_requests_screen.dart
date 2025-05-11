// lib/presentation/screens/technician/requests/technician_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../view_models/technician_request_view_model.dart';
import 'components/request_card.dart';
import 'components/request_filters.dart';
import 'components/empty_requests_view.dart';
import 'components/loading_requests_view.dart';

class TechnicianRequestsScreen extends StatefulWidget {
  const TechnicianRequestsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianRequestsScreenState createState() =>
      _TechnicianRequestsScreenState();
}

class _TechnicianRequestsScreenState extends State<TechnicianRequestsScreen> {
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Cargar solicitudes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TechnicianRequestViewModel>(
        context,
        listen: false,
      ).loadAvailableRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TechnicianRequestViewModel(),
      child: Consumer<TechnicianRequestViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                // Barra superior de filtros
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Solicitudes disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _showFilters
                              ? Icons.filter_list_off
                              : Icons.filter_list,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        tooltip: 'Filtros',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed:
                            viewModel.isLoading
                                ? null
                                : () => viewModel.refreshRequests(),
                        tooltip: 'Actualizar',
                      ),
                    ],
                  ),
                ),

                // Panel de filtros
                if (_showFilters)
                  RequestFilters(
                    onApplyFilters: (filters) {
                      viewModel.applyFilters(filters);
                    },
                  ),

                // Indicador de estado
                if (viewModel.isLoading)
                  LoadingRequestsView()
                else if (viewModel.matchingRequests.isEmpty)
                  EmptyRequestsView(
                    message:
                        viewModel.hasError
                            ? viewModel.errorMessage
                            : 'No hay solicitudes disponibles que coincidan con tu perfil',
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => viewModel.refreshRequests(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.matchingRequests.length,
                        itemBuilder: (context, index) {
                          final request = viewModel.matchingRequests[index];
                          return RequestCard(
                            request: request,
                            onTap: () => _viewRequestDetails(request.id),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _viewRequestDetails(String requestId) {
    // Navegar a la pantalla de detalles de la solicitud
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: requestId),
      ),
    );
  }
}

// Pantalla ficticia para ver los detalles (implementar después)
class RequestDetailScreen extends StatelessWidget {
  final String requestId;

  const RequestDetailScreen({Key? key, required this.requestId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de la solicitud')),
      body: Center(child: Text('Detalles de la solicitud $requestId')),
    );
  }
}
