// lib/presentation/view_models/service_request_view_model.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/service_request_model.dart';
import '../../data/repositories/service_request_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

class ServiceRequestViewModel extends BaseViewModel {
  final ServiceRequestRepository _repository = ServiceRequestRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ServiceRequestModel> _userRequests = [];
  List<ServiceRequestModel> get userRequests => _userRequests;

  ServiceRequestModel? _currentRequest;
  ServiceRequestModel? get currentRequest => _currentRequest;

  // Stream para escuchar cambios en tiempo real
  Stream<List<ServiceRequestModel>>? _requestsStream;

  // Constructor que inicia la escucha
  ServiceRequestViewModel() {
    // Iniciar escucha en tiempo real si hay un usuario autenticado
    if (_auth.currentUser != null) {
      _startRequestsListener();
    }
  }

  // Iniciar escucha en tiempo real
  void _startRequestsListener() {
    _requestsStream = _repository.getUserRequestsStream();

    // Suscribirse al stream
    _requestsStream?.listen(
      (requests) {
        _userRequests = requests;
        notifyListeners();
      },
      onError: (error) {
        print('Error en el stream de solicitudes: $error');
        setError('Error al cargar solicitudes: $error');
      },
    );
  }

  // Load user's service requests (carga inicial)
  Future<void> loadUserServiceRequests() async {
    return executeAsync<void>(() async {
      final user = _auth.currentUser;
      if (user == null) {
        print('No hay usuario autenticado para cargar solicitudes');
        return;
      }

      // Obtener solicitudes desde Firebase
      final requests = await _repository.getUserRequests();

      // Verificar si se obtuvieron solicitudes
      if (requests.isNotEmpty) {
        _userRequests = requests;
        print('Solicitudes cargadas correctamente: ${_userRequests.length}');
      } else {
        print('No se encontraron solicitudes para el usuario ${user.uid}');
        // No usamos datos de prueba si no hay solicitudes reales
        _userRequests = [];
      }

      // Iniciar escucha en tiempo real si no se ha iniciado
      if (_requestsStream == null) {
        _startRequestsListener();
      }
    });
  }

  // Get a specific service request by ID
  Future<void> getServiceRequestById(String requestId) async {
    return executeAsync<void>(() async {
      // Primero verificar si ya está en las solicitudes cargadas
      _currentRequest = _userRequests.firstWhere(
        (request) => request.id == requestId,
        orElse:
            () => ServiceRequestModel(
              id: '',
              userId: '',
              title: '',
              description: '',
              categoryIds: [],
              isUrgent: false,
              inClientLocation: false,
              createdAt: DateTime.now(),
              status: '',
            ),
      );

      // Si no se encontró localmente o es una solicitud vacía, consultar Firebase
      if (_currentRequest!.id.isEmpty) {
        final request = await _repository.getRequestById(requestId);
        if (request != null) {
          _currentRequest = request;
          print('Solicitud cargada desde Firebase: ${request.id}');
        } else {
          print('No se encontró la solicitud en Firebase: $requestId');
          setError('No se encontró la solicitud');
        }
      }
    });
  }

  // Create a new service request
  Future<Resource<String?>> createServiceRequest(
    ServiceRequestModel request,
    List<File>? photos,
  ) async {
    try {
      setLoading();

      final user = _auth.currentUser;
      if (user == null) {
        setError('Usuario no autenticado');
        return Resource.error('Usuario no autenticado');
      }

      // Crear una solicitud con el ID de usuario actual
      final newRequest = request.copyWith(userId: user.uid);

      // Enviar al repositorio con las fotos
      final requestId = await _repository.createServiceRequest(
        newRequest,
        photos,
      );

      if (requestId != null) {
        // Cargar la solicitud creada con el ID asignado
        final createdRequest = newRequest.copyWith(id: requestId);

        // Actualizar la lista local (aunque el stream debería actualizarla pronto)
        _userRequests.insert(0, createdRequest);
        notifyListeners();

        setLoaded();
        return Resource.success(requestId);
      } else {
        setError('Error al crear la solicitud');
        return Resource.error('Error al crear la solicitud');
      }
    } catch (e) {
      final errorMsg = 'Error al crear solicitud: $e';
      setError(errorMsg);
      return Resource.error(errorMsg);
    }
  }

  // Cancel a service request
  Future<Resource<bool>> cancelServiceRequest(String requestId) async {
    try {
      setLoading();

      final user = _auth.currentUser;
      if (user == null) {
        setError('Usuario no autenticado');
        return Resource.error('Usuario no autenticado');
      }

      // Enviar al repositorio
      final success = await _repository.cancelRequest(requestId);

      if (success) {
        // Actualizar la lista local (aunque el stream debería actualizarla pronto)
        final index = _userRequests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          _userRequests[index] = _userRequests[index].copyWith(
            status: 'cancelled',
          );

          // Si la solicitud actual es la que se está cancelando, actualizarla también
          if (_currentRequest != null && _currentRequest!.id == requestId) {
            _currentRequest = _currentRequest!.copyWith(status: 'cancelled');
          }

          notifyListeners();
        }

        setLoaded();
        return Resource.success(true);
      } else {
        setError('Error al cancelar la solicitud');
        return Resource.error('Error al cancelar la solicitud');
      }
    } catch (e) {
      final errorMsg = 'Error al cancelar solicitud: $e';
      setError(errorMsg);
      return Resource.error(errorMsg);
    }
  }

  @override
  void dispose() {
    // Limpiar recursos al destruir el ViewModel
    _requestsStream = null;
    super.dispose();
  }
}
