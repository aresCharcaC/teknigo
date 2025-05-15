// lib/presentation/view_models/service_status_view_model.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/service_model.dart';
import '../../core/enums/service_enums.dart';
import '../../data/repositories/service_status_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

class ServiceStatusViewModel extends BaseViewModel {
  final ServiceStatusRepository _repository = ServiceStatusRepository();
  final ChatRepository _chatRepository = ChatRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ServiceModel? _currentService;
  ServiceModel? get currentService => _currentService;

  bool _isClient = false;
  bool get isClient => _isClient;

  bool _isTechnician = false;
  bool get isTechnician => _isTechnician;

  String? _currentConfirmationMessageId;

  // Load service related to a chat
  Future<void> loadServiceByChatId(String chatId) async {
    return executeAsync<void>(() async {
      print('ServiceStatusViewModel: Loading service for chat: $chatId');

      // Asegúrate de que el chat ID no esté vacío
      if (chatId.isEmpty) {
        print('ServiceStatusViewModel: Chat ID is empty!');
        return;
      }

      final service = await _repository.getServiceByChatId(chatId);

      if (service != null) {
        print(
          'ServiceStatusViewModel: Service found: ${service.id}, status: ${service.status}',
        );
        _currentService = service;

        // Determine roles
        final currentUserId = _auth.currentUser?.uid;
        if (currentUserId != null) {
          _isClient = currentUserId == service.clientId;
          _isTechnician = currentUserId == service.technicianId;
          print(
            'ServiceStatusViewModel: User roles - isClient: $_isClient, isTechnician: $_isTechnician',
          );
        } else {
          print(
            'ServiceStatusViewModel: No current user, cant determine roles',
          );
        }
      } else {
        print('ServiceStatusViewModel: No service found for chat: $chatId');
      }
    });
  }

  Future<Resource<bool>> changeServiceStatus(ServiceStatus newStatus) async {
    try {
      if (_currentService == null) {
        return Resource.error('No hay servicio activo');
      }

      // No verificamos roles para permitir cambios más flexibles

      setLoading();

      bool result = false;

      // Implementar la lógica según el estado destino
      switch (newStatus) {
        case ServiceStatus.accepted:
          result = await _repository.updateServiceStatus(
            _currentService!.id,
            newStatus,
          );
          break;
        case ServiceStatus.inProgress:
          result = await _repository.startService(_currentService!.id);
          break;
        case ServiceStatus.completed:
          result = await _repository.completeService(_currentService!.id);
          break;
        case ServiceStatus.rated:
          // Calificar con 5 estrellas por defecto
          result = await _repository.rateService(
            _currentService!.id,
            5.0,
            "Trabajo satisfactorio",
          );
          break;
        default:
          result = await _repository.updateServiceStatus(
            _currentService!.id,
            newStatus,
          );
          break;
      }

      if (result) {
        // Enviar mensaje según el nuevo estado
        String statusMessage = _getStatusChangeMessage(newStatus);
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content: statusMessage,
        );

        // Update local service
        _currentService = _currentService!.copyWith(status: newStatus);
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al cambiar el estado del servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Obtener mensaje según el nuevo estado
  String _getStatusChangeMessage(ServiceStatus newStatus) {
    switch (newStatus) {
      case ServiceStatus.accepted:
        return "✅ El servicio ha sido aceptado. ¡Gracias por confiar en nosotros!";
      case ServiceStatus.inProgress:
        return "🔧 He iniciado el trabajo. Te mantendré informado del progreso.";
      case ServiceStatus.completed:
        return "✅ He marcado el trabajo como completado. ¿Estás satisfecho con el servicio?";
      case ServiceStatus.rated:
        return "⭐⭐⭐⭐⭐ ¡Servicio calificado con 5 estrellas! ¡Gracias por elegir nuestros servicios!";
      default:
        return "Estado del servicio actualizado a: ${newStatus.toString().split('.').last}";
    }
  }

  // Accept a service (client)
  Future<Resource<bool>> acceptService(double agreedPrice) async {
    try {
      if (_currentService == null) {
        return Resource.error('No active service');
      }

      if (!_isClient) {
        return Resource.error('Only the client can accept a service');
      }

      setLoading();

      final result = await _repository.acceptService(
        _currentService!.id,
        agreedPrice,
      );

      if (result) {
        // Send message to chat
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content:
              "✅ Servicio aceptado con precio: S/ ${agreedPrice.toStringAsFixed(2)}",
        );

        // Update local service
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.accepted,
          acceptedAt: DateTime.now(),
          agreedPrice: agreedPrice,
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al aceptar el servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Start service (technician)
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
        // Send message to chat
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content: "🔧 El técnico ha iniciado el trabajo",
        );

        // Update local service
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.inProgress,
          inProgressAt: DateTime.now(),
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al iniciar el servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Complete service (technician)
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
        // Enviar mensaje de confirmación en lugar de un mensaje normal
        final confirmSent = await _chatRepository
            .sendCompletionConfirmationMessage(
              chatId: _currentService!.chatId,
              clientId: _currentService!.clientId,
            );

        // Update local service
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.completed,
          completedAt: DateTime.now(),
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al completar el servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Confirmar completado y calificar (cliente)
  Future<Resource<bool>> confirmCompletionAndRate() async {
    try {
      if (_currentService == null) {
        return Resource.error('No hay servicio activo');
      }

      if (!_isClient) {
        return Resource.error('Solo el cliente puede confirmar el servicio');
      }

      setLoading();

      // Por simplificar, asignamos una calificación predeterminada 5.0
      const double defaultRating = 5.0;

      final result = await _repository.rateService(
        _currentService!.id,
        defaultRating,
        "Trabajo satisfactorio",
      );

      if (result) {
        // Actualizar mensaje de confirmación como respondido
        if (_currentConfirmationMessageId != null) {
          await _chatRepository.updateConfirmationMessageAsResponded(
            _currentConfirmationMessageId!,
          );
        }

        // Enviar mensaje normal de confirmación
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content:
              "✅ He confirmado el trabajo como completado. ¡Gracias por tu servicio! (Calificación: ⭐⭐⭐⭐⭐)",
        );

        // Update local service
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.rated,
          finishedAt: DateTime.now(),
          clientRating: defaultRating,
          clientReview: "Trabajo satisfactorio",
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al confirmar el servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Rechazar completado (cliente)
  Future<Resource<bool>> rejectCompletion() async {
    try {
      if (_currentService == null) {
        return Resource.error('No hay servicio activo');
      }

      if (!_isClient) {
        return Resource.error('Solo el cliente puede rechazar la confirmación');
      }

      setLoading();

      // Revertir el estado a "en progreso"
      final result = await _repository.revertToInProgress(_currentService!.id);

      if (result) {
        // Actualizar mensaje de confirmación
        if (_currentConfirmationMessageId != null) {
          await _chatRepository.updateConfirmationMessageAsResponded(
            _currentConfirmationMessageId!,
          );
        }

        // Enviar mensaje de rechazo
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content:
              "❌ He rechazado la confirmación. El trabajo aún no está completado.",
        );

        // Update local service
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.inProgress,
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al rechazar la confirmación: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Rate service (client)
  Future<Resource<bool>> rateService(double rating, String? comment) async {
    try {
      if (_currentService == null) {
        return Resource.error('No hay servicio activo');
      }

      if (!_isClient) {
        return Resource.error('Solo el cliente puede calificar el servicio');
      }

      setLoading();

      final result = await _repository.rateService(
        _currentService!.id,
        rating,
        comment,
      );

      if (result) {
        // Send message to chat with star emojis based on rating
        String stars = '';
        for (int i = 0; i < rating.round(); i++) {
          stars += '⭐';
        }

        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content:
              "$stars Servicio calificado con $rating estrellas" +
              (comment != null ? ": $comment" : ""),
        );

        // Update local service
        _currentService = _currentService!.copyWith(
          status: ServiceStatus.rated,
          finishedAt: DateTime.now(),
          clientRating: rating,
          clientReview: comment,
        );
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al calificar el servicio: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }
}
