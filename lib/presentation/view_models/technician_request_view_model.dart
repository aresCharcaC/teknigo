// lib/presentation/view_models/technician_request_view_model.dart
// (actualizamos la clase existente)

import 'package:flutter/material.dart';
import '../../core/models/service_request_model.dart';
import '../../data/repositories/technician_request_repository.dart';
import '../common/base_view_model.dart';
import '../screens/technician/requests/components/request_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TechnicianRequestViewModel extends BaseViewModel {
  final TechnicianRequestRepository _repository = TechnicianRequestRepository();

  List<ServiceRequestModel> _allRequests = [];
  List<ServiceRequestModel> _matchingRequests = [];
  List<ServiceRequestModel> get matchingRequests => _matchingRequests;

  // Lista de IDs de solicitudes ignoradas/rechazadas
  Set<String> _ignoredRequestIds = {};
  Set<String> get ignoredRequestIds => _ignoredRequestIds;

  RequestFilterModel _currentFilters = RequestFilterModel();

  // Solicitud actual para la vista detallada
  ServiceRequestModel? _selectedRequest;
  ServiceRequestModel? get selectedRequest => _selectedRequest;

  // Propiedad para controlar si se muestran o no las solicitudes ignoradas
  bool _showIgnoredRequests = false;
  bool get showIgnoredRequests => _showIgnoredRequests;

  TechnicianRequestViewModel() {
    _loadIgnoredRequests();
  }

  // Cargar solicitudes ignoradas desde shared preferences
  Future<void> _loadIgnoredRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ignoredIds = prefs.getStringList('ignored_request_ids') ?? [];
      _ignoredRequestIds = Set<String>.from(ignoredIds);
    } catch (e) {
      print('Error loading ignored requests: $e');
    }
  }

  // Obtener una solicitud por ID
  Future<ServiceRequestModel?> getRequestById(String requestId) async {
    try {
      if (requestId.isEmpty) return null;

      // Primero buscamos en nuestras listas en memoria
      ServiceRequestModel? request = _allRequests.firstWhere(
        (req) => req.id == requestId,
        orElse: () => null as ServiceRequestModel,
      );

      // Si no se encuentra en memoria, buscamos en la base de datos
      if (request == null) {
        request = await _repository.getRequestById(requestId);
      }

      // Si se encontró la solicitud, actualizamos la selección actual
      if (request != null) {
        _selectedRequest = request;
      }

      return request;
    } catch (e) {
      setError('Error al obtener la solicitud: $e');
      return null;
    }
  }

  // Guardar solicitudes ignoradas en shared preferences
  Future<void> _saveIgnoredRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'ignored_request_ids',
        _ignoredRequestIds.toList(),
      );
    } catch (e) {
      print('Error saving ignored requests: $e');
    }
  }

  // Cargar solicitudes disponibles para el técnico
  Future<void> loadAvailableRequests() async {
    return executeAsync<void>(() async {
      // Cargar solicitudes ignoradas si no se han cargado ya
      if (_ignoredRequestIds.isEmpty) {
        await _loadIgnoredRequests();
      }

      // Obtener solicitudes según perfil del técnico
      final requests = await _repository.getAvailableRequests();

      // Si se está mostrando todo, guardamos todas las solicitudes
      if (_showIgnoredRequests) {
        _allRequests = requests;
      } else {
        // Si no, filtramos las solicitudes ignoradas
        _allRequests =
            requests
                .where((request) => !_ignoredRequestIds.contains(request.id))
                .toList();
      }

      // Aplicar filtros actuales
      _applyCurrentFilters();
    });
  }

  // Método para "recuperar" una solicitud ignorada
  Future<void> recoverIgnoredRequest(String requestId) async {
    if (requestId.isEmpty) return;

    // Quitar de la lista de ignorados
    _ignoredRequestIds.remove(requestId);

    // Guardar en preferences
    await _saveIgnoredRequests();

    // Recargar datos
    await refreshRequests();

    notifyListeners();
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

  // Método para cambiar la visibilidad de las solicitudes ignoradas
  void toggleShowIgnoredRequests() {
    _showIgnoredRequests = !_showIgnoredRequests;
    refreshRequests(); // Recarga las solicitudes con la nueva configuración
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

  // Seleccionar una solicitud para ver en detalle
  void selectRequest(String requestId) {
    _selectedRequest = _allRequests.firstWhere(
      (request) => request.id == requestId,
      orElse: () => null as ServiceRequestModel,
    );
    notifyListeners();
  }

  // Marcar una solicitud como "No me interesa"
  Future<void> ignoreRequest(String requestId) async {
    if (requestId.isEmpty) return;

    // Añadir a la lista de ignorados
    _ignoredRequestIds.add(requestId);

    // Actualizar listas locales
    _allRequests.removeWhere((request) => request.id == requestId);
    _applyCurrentFilters();

    // Guardar en preferences
    await _saveIgnoredRequests();

    // Limpiar la selección actual si es la misma
    if (_selectedRequest != null && _selectedRequest!.id == requestId) {
      _selectedRequest = null;
    }

    notifyListeners();
  }
}
