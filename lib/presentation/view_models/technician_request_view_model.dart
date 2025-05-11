// lib/presentation/view_models/technician_request_view_model.dart
import 'package:flutter/material.dart';
import '../../core/models/service_request_model.dart';
import '../../data/repositories/technician_request_repository.dart';
import '../common/base_view_model.dart';
import '../screens/technician/requests/components/request_filters.dart';

class TechnicianRequestViewModel extends BaseViewModel {
  final TechnicianRequestRepository _repository = TechnicianRequestRepository();

  List<ServiceRequestModel> _allRequests = [];
  List<ServiceRequestModel> _matchingRequests = [];
  List<ServiceRequestModel> get matchingRequests => _matchingRequests;

  RequestFilterModel _currentFilters = RequestFilterModel();

  // Cargar solicitudes disponibles para el técnico
  Future<void> loadAvailableRequests() async {
    return executeAsync<void>(() async {
      // Obtener solicitudes según perfil del técnico
      final requests = await _repository.getAvailableRequests();

      // Guardar todas las solicitudes
      _allRequests = requests;

      // Aplicar filtros actuales
      _applyCurrentFilters();
    });
  }

  // Refrescar solicitudes
  Future<void> refreshRequests() async {
    return loadAvailableRequests();
  }

  // Aplicar filtros
  void applyFilters(RequestFilterModel filters) {
    _currentFilters = filters;
    _applyCurrentFilters();
    notifyListeners();
  }

  // Aplicar filtros internamente
  void _applyCurrentFilters() {
    // Comenzar con todas las solicitudes
    _matchingRequests = List.from(_allRequests);

    // Filtrar por urgencia si está activado
    if (_currentFilters.onlyUrgent) {
      _matchingRequests =
          _matchingRequests.where((request) => request.isUrgent).toList();
    }

    // Filtrar por servicio a domicilio si está activado
    if (_currentFilters.onlyHomeService) {
      _matchingRequests =
          _matchingRequests
              .where((request) => request.inClientLocation)
              .toList();
    }

    // Filtrar por categoría si está seleccionada
    if (_currentFilters.categoryFilter != null) {
      _matchingRequests =
          _matchingRequests
              .where(
                (request) => request.categoryIds.contains(
                  _currentFilters.categoryFilter,
                ),
              )
              .toList();
    }
  }
}
