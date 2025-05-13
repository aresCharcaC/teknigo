// lib/presentation/view_models/proposal_view_model.dart
import 'package:flutter/material.dart';
import '../../core/models/proposal_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

class ProposalViewModel extends BaseViewModel {
  final ChatRepository _repository = ChatRepository();

  // Enviar una nueva propuesta
  Future<Resource<String?>> sendProposal({
    required String requestId,
    required String clientId,
    required ProposalModel proposal,
  }) async {
    try {
      setLoading();

      final chatId = await _repository.createChatWithProposal(
        requestId: requestId,
        clientId: clientId,
        message: proposal.message,
        price: proposal.price,
        availability: proposal.availability,
      );

      if (chatId != null) {
        setLoaded();
        return Resource.success(chatId);
      } else {
        setError('No se pudo crear el chat con la propuesta');
        return Resource.error('No se pudo crear el chat con la propuesta');
      }
    } catch (e) {
      final errorMsg = 'Error al enviar propuesta: $e';
      setError(errorMsg);
      return Resource.error(errorMsg);
    }
  }
}
