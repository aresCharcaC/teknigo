import 'package:flutter/material.dart';
import '../../core/models/pending_confirmation_model.dart';
import '../../data/repositories/confirmation_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

class ConfirmationViewModel extends BaseViewModel {
  final ConfirmationRepository _confirmationRepository =
      ConfirmationRepository();
  final ChatRepository _chatRepository = ChatRepository();

  PendingConfirmationModel? _pendingConfirmation;
  PendingConfirmationModel? get pendingConfirmation => _pendingConfirmation;

  // Cargar confirmación pendiente para un chat específico
  Future<bool> loadPendingConfirmationForChat(String chatId) async {
    try {
      setLoading();

      final confirmation = await _confirmationRepository
          .getPendingConfirmationForChat(chatId);
      _pendingConfirmation = confirmation;

      setLoaded();
      return confirmation != null;
    } catch (e) {
      setError('Error al cargar confirmación pendiente: $e');
      return false;
    }
  }

  // Resolver una confirmación pendiente
  Future<Resource<bool>> resolveConfirmation(bool isAccepted) async {
    try {
      if (_pendingConfirmation == null) {
        return Resource.error('No hay confirmación pendiente');
      }

      setLoading();

      // Resolver la confirmación en la base de datos
      final result = await _confirmationRepository.resolveConfirmation(
        confirmationId: _pendingConfirmation!.id,
        isAccepted: isAccepted,
      );

      if (result) {
        // Enviar mensaje al chat
        final message =
            isAccepted
                ? "✅ He confirmado que el trabajo está completado correctamente."
                : "❌ He indicado que el trabajo aún no está completado.";

        await _chatRepository.sendTextMessage(
          chatId: _pendingConfirmation!.chatId,
          content: message,
        );

        // Actualizar el modelo local
        _pendingConfirmation = null;
      }

      setLoaded();
      return Resource.success(result);
    } catch (e) {
      final errorMessage = 'Error al resolver confirmación: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }
}
