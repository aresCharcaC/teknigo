import 'package:flutter/material.dart';
import '../../data/repositories/technician_repository.dart';
import '../common/base_view_model.dart';
import '../screens/technician/requests/technician_requests_screen.dart';

/// ViewModel para gestionar las solicitudes de servicio
class ServiceRequestViewModel extends BaseViewModel {
  final TechnicianRepository _repository = TechnicianRepository();

  // Listas de solicitudes
  List<ServiceRequest> _pendingRequests = [];
  List<ServiceRequest> get pendingRequests => _pendingRequests;

  List<ServiceRequest> _acceptedServices = [];
  List<ServiceRequest> get acceptedServices => _acceptedServices;

  List<ServiceRequest> _completedServices = [];
  List<ServiceRequest> get completedServices => _completedServices;

  // Cargar solicitudes pendientes
  Future<void> loadPendingRequests() async {
    executeAsync(() async {
      // Datos simulados para pruebas
      _pendingRequests = [
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

      // En la implementación real, obtendríamos los datos del repositorio:
      // final data = await _repository.getPendingRequests();
      // Procesaríamos los datos para crear la lista de solicitudes
    });
  }

  // Cargar servicios aceptados
  Future<void> loadAcceptedServices() async {
    executeAsync(() async {
      // Datos simulados para pruebas
      _acceptedServices = [
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

      // En la implementación real, obtendríamos los datos del repositorio:
      // final data = await _repository.getAcceptedServices();
      // Procesaríamos los datos para crear la lista de servicios
    });
  }

  // Cargar servicios completados
  Future<void> loadCompletedServices() async {
    executeAsync(() async {
      // Datos simulados para pruebas
      _completedServices = [
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
          acceptedAt: DateTime.now().subtract(
            const Duration(days: 2, hours: 1),
          ),
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
          acceptedAt: DateTime.now().subtract(
            const Duration(days: 4, hours: 2),
          ),
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
          rating: 4.5,
          review: 'Buen trabajo, recomendado.',
        ),
      ];

      // En la implementación real, obtendríamos los datos del repositorio:
      // final data = await _repository.getCompletedServices();
      // Procesaríamos los datos para crear la lista de servicios
    });
  }

  // Aceptar una solicitud
  Future<void> acceptRequest(String requestId) async {
    executeAsync(() async {
      // Encontrar la solicitud
      final request = _pendingRequests.firstWhere((req) => req.id == requestId);

      // Crear nueva solicitud con los datos actualizados
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
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
      );

      // Actualizar listas
      _pendingRequests.removeWhere((req) => req.id == requestId);
      _acceptedServices.add(updatedRequest);

      // En la implementación real, actualizaríamos en el repositorio:
      // await _repository.acceptRequest(requestId);

      notifyListeners();
    });
  }

  // Rechazar una solicitud
  Future<void> rejectRequest(String requestId) async {
    executeAsync(() async {
      // Actualizar lista
      _pendingRequests.removeWhere((req) => req.id == requestId);

      // En la implementación real, actualizaríamos en el repositorio:
      // await _repository.rejectRequest(requestId);

      notifyListeners();
    });
  }

  // Completar un servicio
  Future<void> completeService(String serviceId) async {
    executeAsync(() async {
      // Encontrar el servicio
      final service = _acceptedServices.firstWhere(
        (req) => req.id == serviceId,
      );

      // Crear nuevo servicio con los datos actualizados
      final updatedService = ServiceRequest(
        id: service.id,
        clientName: service.clientName,
        category: service.category,
        description: service.description,
        location: service.location,
        distance: service.distance,
        createdAt: service.createdAt,
        budget: service.budget,
        isUrgent: service.isUrgent,
        acceptedAt: service.acceptedAt,
        scheduledDate: service.scheduledDate,
        completedAt: DateTime.now(),
      );

      // Actualizar listas
      _acceptedServices.removeWhere((req) => req.id == serviceId);
      _completedServices.add(updatedService);

      // En la implementación real, actualizaríamos en el repositorio:
      // await _repository.completeService(serviceId);

      notifyListeners();
    });
  }
}
