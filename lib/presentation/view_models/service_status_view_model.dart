// lib/presentation/view_models/service_status_view_model.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/service_model.dart';
import '../../core/enums/service_enums.dart';
import '../../data/repositories/service_status_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/confirmation_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

class ServiceStatusViewModel extends BaseViewModel {
  final ServiceStatusRepository _repository = ServiceStatusRepository();
  final ChatRepository _chatRepository = ChatRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConfirmationRepository _confirmationRepository =
      ConfirmationRepository();

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

      setLoading();

      // Guardar el estado anterior para mensajes informativos
      final oldStatus = _currentService!.status;

      // Llamar al método genérico del repositorio
      bool result = await _repository.updateServiceStatus(
        _currentService!.id,
        newStatus,
      );

      if (result) {
        // Enviar mensaje informativo sobre el cambio de estado
        String statusMessage =
            "🔄 Estado cambiado de ${_getStatusText(oldStatus)} a ${_getStatusText(newStatus)}";

        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content: statusMessage,
        );

        // Actualizar servicio local
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

  // Obtener texto según estado (para mensajes)
  String _getStatusText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return 'PENDIENTE';
      case ServiceStatus.offered:
        return 'PROPUESTA ENVIADA';
      case ServiceStatus.accepted:
        return 'SERVICIO ACEPTADO';
      case ServiceStatus.inProgress:
        return 'TRABAJO EN PROGRESO';
      case ServiceStatus.completed:
        return 'TRABAJO COMPLETADO';
      case ServiceStatus.rated:
        return 'SERVICIO FINALIZADO';
      case ServiceStatus.cancelled:
        return 'SERVICIO CANCELADO';
      case ServiceStatus.rejected:
        return 'PROPUESTA RECHAZADA';
      default:
        return 'ESTADO DESCONOCIDO';
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
        // Enviar mensaje normal
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content:
              "✅ He marcado el trabajo como completado. El cliente debe confirmar.",
        );

        // Crear confirmación pendiente - Nuevo
        final confirmationId = await _confirmationRepository
            .createPendingConfirmation(
              serviceId: _currentService!.id,
              chatId: _currentService!.chatId,
              technicianId: _currentService!.technicianId ?? '',
              clientId: _currentService!.clientId,
              serviceTitle: _currentService!.title,
            );
        print('Confirmación pendiente creada con ID: $confirmationId');

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
  Future<Resource<bool>> confirmCompletionAndRate(
    String confirmationMessageId,
  ) async {
    try {
      if (_currentService == null) {
        print("Error: No hay servicio activo al confirmar");
        return Resource.error('No hay servicio activo');
      }

      if (!_isClient) {
        print("Error: Solo el cliente puede confirmar el servicio");
        return Resource.error('Solo el cliente puede confirmar el servicio');
      }

      setLoading();

      print(
        "Iniciando confirmación del servicio - messageId: $confirmationMessageId",
      );

      // Marcar el mensaje de confirmación como respondido y confirmado
      if (confirmationMessageId.isNotEmpty) {
        print("Actualizando mensaje de confirmación como respondido");
        await _chatRepository.updateConfirmationMessageAsResponded(
          confirmationMessageId,
          true, // isConfirmed = true
        );
      } else {
        print("Error: ID de mensaje de confirmación vacío");
      }

      // Actualizar servicio a estado COMPLETADO si no lo está ya
      if (_currentService!.status != ServiceStatus.completed) {
        print("Actualizando estado del servicio a COMPLETADO");
        await _repository.updateServiceStatus(
          _currentService!.id,
          ServiceStatus.completed,
        );
      }

      // Guardar el ID del mensaje de confirmación para usar más tarde
      _currentConfirmationMessageId = confirmationMessageId;

      // Enviar mensaje normal de confirmación
      await _chatRepository.sendTextMessage(
        chatId: _currentService!.chatId,
        content:
            "✅ He confirmado que el trabajo está completado. Ahora por favor califica el servicio.",
      );

      // Update local service
      _currentService = _currentService!.copyWith(
        status: ServiceStatus.completed,
        finishedAt: DateTime.now(),
      );

      setLoaded();
      print("Servicio confirmado exitosamente");
      return Resource.success(true);
    } catch (e) {
      final errorMessage = 'Error al confirmar el servicio: $e';
      print("ERROR: $errorMessage");
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Rechazar completado (cliente)
  Future<Resource<bool>> rejectCompletion(String confirmationMessageId) async {
    try {
      if (_currentService == null) {
        print("Error: No hay servicio activo al rechazar");
        return Resource.error('No hay servicio activo');
      }

      if (!_isClient) {
        print("Error: Solo el cliente puede rechazar la confirmación");
        return Resource.error('Solo el cliente puede rechazar la confirmación');
      }

      setLoading();
      print(
        "Rechazando finalización del servicio - messageId: $confirmationMessageId",
      );

      // Revertir el estado a "en progreso"
      final result = await _repository.revertToInProgress(_currentService!.id);

      if (result) {
        // Actualizar mensaje de confirmación como respondido pero rechazado
        if (confirmationMessageId.isNotEmpty) {
          print("Actualizando mensaje de confirmación como rechazado");
          await _chatRepository.updateConfirmationMessageAsResponded(
            confirmationMessageId,
            false, // isConfirmed = false
          );
        } else {
          print("Error: ID de mensaje de confirmación vacío");
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
      print("Servicio rechazado exitosamente");
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al rechazar la confirmación: $e';
      print("ERROR: $errorMessage");
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

        // Update local service - CAMBIAR EL ESTADO A RATED
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
