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

  // Load service related to a chat
  Future<void> loadServiceByChatId(String chatId) async {
    return executeAsync<void>(() async {
      print('Loading service for chat: $chatId');

      final service = await _repository.getServiceByChatId(chatId);

      if (service != null) {
        print('Service found: ${service.id}, status: ${service.status}');
        _currentService = service;

        // Determine roles
        final currentUserId = _auth.currentUser?.uid;
        _isClient = currentUserId == service.clientId;
        _isTechnician = currentUserId == service.technicianId;

        print('Roles: isClient=$_isClient, isTechnician=$_isTechnician');
      } else {
        print('No service found for this chat');
      }
    });
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
              "✅ Service accepted with price: \$${agreedPrice.toStringAsFixed(2)}",
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
      final errorMessage = 'Error accepting service: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Start service (technician)
  Future<Resource<bool>> startService() async {
    try {
      if (_currentService == null) {
        return Resource.error('No active service');
      }

      if (!_isTechnician) {
        return Resource.error('Only the technician can start the service');
      }

      setLoading();

      final result = await _repository.startService(_currentService!.id);

      if (result) {
        // Send message to chat
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content: "🔧 The technician has started working",
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
      final errorMessage = 'Error starting service: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Complete service (technician)
  Future<Resource<bool>> completeService() async {
    try {
      if (_currentService == null) {
        return Resource.error('No active service');
      }

      if (!_isTechnician) {
        return Resource.error('Only the technician can complete the service');
      }

      setLoading();

      final result = await _repository.completeService(_currentService!.id);

      if (result) {
        // Send message to chat
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content:
              "✅ The work has been completed. Please confirm and rate the service.",
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
      final errorMessage = 'Error completing service: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Rate service (client)
  Future<Resource<bool>> rateService(double rating, String? comment) async {
    try {
      if (_currentService == null) {
        return Resource.error('No active service');
      }

      if (!_isClient) {
        return Resource.error('Only the client can rate the service');
      }

      setLoading();

      final result = await _repository.rateService(
        _currentService!.id,
        rating,
        comment,
      );

      if (result) {
        // Send message to chat
        await _chatRepository.sendTextMessage(
          chatId: _currentService!.chatId,
          content:
              "⭐ Service rated with $rating stars" +
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
      final errorMessage = 'Error rating service: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }
}
