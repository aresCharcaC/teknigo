// lib/presentation/view_models/service_status_view_model.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Asegúrate de importar esto
import '../../core/models/service_model.dart';
import '../../core/enums/service_enums.dart';
import '../../data/repositories/service_status_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

class ServiceStatusViewModel extends BaseViewModel {
  final ServiceStatusRepository _repository = ServiceStatusRepository();
  final ChatRepository _chatRepository = ChatRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Añade esto aquí

  ServiceModel? _currentService;
  ServiceModel? get currentService => _currentService;

  bool _isClient = false;
  bool get isClient => _isClient;

  bool _isTechnician = false;
  bool get isTechnician => _isTechnician;

  // Cargar servicio relacionado a un chat
  Future<void> loadServiceByChatId(String chatId) async {
    return executeAsync<void>(() async {
      // Imprimir información de depuración
      print('Cargando servicio para chat: $chatId');

      final service = await _repository.getServiceByChatId(chatId);

      if (service != null) {
        print('Servicio encontrado: ${service.id}, estado: ${service.status}');
        _currentService = service;

        // Determinar roles
        final currentUserId = _auth.currentUser?.uid;
        _isClient = currentUserId == service.clientId;
        _isTechnician = currentUserId == service.technicianId;

        print('Roles: isClient=$_isClient, isTechnician=$_isTechnician');
      } else {
        print('No se encontró servicio para este chat');
      }
    });
  }

  // Aceptar un servicio (cliente)
  Future<Resource<bool>> acceptService(double agreedPrice) async {
    try {
      if (_currentService == null) {
        return Resource.error('No hay servicio activo');
      }

      if (!_isClient) {
        return Resource.error('Solo el cliente puede aceptar un servicio');
      }

      setLoading();

      final result = await _repository.acceptService(
        _currentService!.id,
        agreedPrice,
      );

      if (result) {
        // Enviar mensaje al chat
        await _chatRepository.sendTextMessage(
          chatId:
              _currentService!
                  .id, // Corregido: usamos el ID del servicio para el chat
          content:
              "✅ Servicio aceptado con precio: \$${agreedPrice.toStringAsFixed(2)}",
        );

        // Actualizar servicio local
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.accepted,
          acceptedAt: DateTime.now(),
          agreedPrice: agreedPrice,
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al aceptar servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // El resto del código sigue igual...
  // Iniciar servicio (técnico)
  Future<Resource<bool>> startService() async {
    try {
      if (_currentService == null) {
        return Resource.error('No hay servicio activo');
      }

      if (!_isTechnician) {
        return Resource.error('Solo el técnico puede iniciar el servicio');
      }

      setLoading();

      final result = await _repository.startService(_currentService!.id);

      if (result) {
        // Enviar mensaje al chat
        await _chatRepository.sendTextMessage(
          chatId:
              _currentService!
                  .id, // Corregido: usamos el ID del servicio para el chat
          content: "🔧 El técnico ha iniciado el trabajo",
        );

        // Actualizar servicio local
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.inProgress,
          inProgressAt: DateTime.now(),
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al iniciar servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Completar servicio (técnico)
  Future<Resource<bool>> completeService() async {
    try {
      if (_currentService == null) {
        return Resource.error('No hay servicio activo');
      }

      if (!_isTechnician) {
        return Resource.error('Solo el técnico puede completar el servicio');
      }

      setLoading();

      final result = await _repository.completeService(_currentService!.id);

      if (result) {
        // Enviar mensaje al chat
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.id, // Corregido
          content:
              "✅ El trabajo ha sido completado. Por favor confirma y califica el servicio.",
        );

        // Actualizar servicio local
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.completed,
          completedAt: DateTime.now(),
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al completar servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }
}
