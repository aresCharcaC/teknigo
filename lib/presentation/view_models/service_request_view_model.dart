import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/service_request_model.dart';
import '../common/base_view_model.dart';

class ServiceRequestViewModel extends BaseViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ServiceRequestModel> _userRequests = [];
  List<ServiceRequestModel> get userRequests => _userRequests;

  ServiceRequestModel? _currentRequest;
  ServiceRequestModel? get currentRequest => _currentRequest;

  // Load user's service requests
  Future<void> loadUserServiceRequests() async {
    return executeAsync<void>(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      // Query Firestore for user's requests
      final snapshot =
          await _firestore
              .collection('service_requests')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .get();

      // Convert to model objects
      _userRequests =
          snapshot.docs
              .map((doc) => ServiceRequestModel.fromFirestore(doc))
              .toList();

      // If Firestore is empty or not yet set up, use mock data
      if (_userRequests.isEmpty) {
        _userRequests = _getMockRequests(user.uid);
      }
    });
  }

  // Get a specific service request by ID
  Future<void> getServiceRequestById(String requestId) async {
    return executeAsync<void>(() async {
      // First check if it's already in the loaded requests
      _currentRequest = _userRequests.firstWhere(
        (request) => request.id == requestId,
        orElse: () => _findMockRequestById(requestId),
      );

      // If not found locally, query Firestore
      if (_currentRequest == null) {
        try {
          final doc =
              await _firestore
                  .collection('service_requests')
                  .doc(requestId)
                  .get();

          if (doc.exists) {
            _currentRequest = ServiceRequestModel.fromFirestore(doc);
          }
        } catch (e) {
          print('Error fetching request: $e');
          setError('Error al cargar la solicitud: $e');
        }
      }
    });
  }

  // Create a new service request
  Future<void> createServiceRequest(ServiceRequestModel request) async {
    return executeAsync<void>(() async {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // For now, simulate Firestore operation
      // In production, this would write to Firestore

      // Add request with user ID
      final newRequest = ServiceRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        title: request.title,
        description: request.description,
        categoryIds: request.categoryIds,
        isUrgent: request.isUrgent,
        inClientLocation: request.inClientLocation,
        address: request.address,
        createdAt: DateTime.now(),
        scheduledDate: request.scheduledDate,
        photos: request.photos,
        status: 'pending',
      );

      // Add to local list
      _userRequests.insert(0, newRequest);

      // In production:
      // await _firestore.collection('service_requests').add(newRequest.toFirestore());
    });
  }

  // Cancel a service request
  Future<void> cancelServiceRequest(String requestId) async {
    return executeAsync<void>(() async {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Find the request to cancel
      final index = _userRequests.indexWhere((r) => r.id == requestId);
      if (index == -1) throw Exception('Solicitud no encontrada');

      // Update status to cancelled
      final updatedRequest = _userRequests[index].copyWith(status: 'cancelled');
      _userRequests[index] = updatedRequest;

      // In production:
      // await _firestore
      //   .collection('service_requests')
      //   .doc(requestId)
      //   .update({'status': 'cancelled'});
    });
  }

  // Mock data for testing - will be replaced with Firestore data
  List<ServiceRequestModel> _getMockRequests(String userId) {
    return [
      ServiceRequestModel(
        id: '1',
        userId: userId,
        title: 'Reparación de refrigerador',
        description: 'Mi refrigerador no enfría correctamente desde ayer',
        categoryIds: ['8'], // Refrigeración
        isUrgent: true,
        inClientLocation: true,
        address: 'Av. Arequipa 123, Arequipa',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'pending',
        proposalCount: 0,
      ),
      ServiceRequestModel(
        id: '2',
        userId: userId,
        title: 'Instalación de interruptores',
        description: 'Necesito instalar 3 interruptores nuevos en mi sala',
        categoryIds: ['1'], // Electricista
        isUrgent: false,
        inClientLocation: true,
        address: 'Calle Los Arces 456, Arequipa',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
        proposalCount: 2,
      ),
      ServiceRequestModel(
        id: '3',
        userId: userId,
        title: 'Formateo de laptop',
        description:
            'Mi laptop está muy lenta, necesito formatearla e instalar Windows 10',
        categoryIds: ['5'], // Técnico PC
        isUrgent: false,
        inClientLocation: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: 'accepted',
        proposalCount: 3,
      ),
      ServiceRequestModel(
        id: '4',
        userId: userId,
        title: 'Reparación de fuga de agua',
        description:
            'Tengo una fuga en el baño que necesita reparación urgente',
        categoryIds: ['3'], // Plomero
        isUrgent: true,
        inClientLocation: true,
        address: 'Urb. El Palacio 789, Arequipa',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        proposalCount: 4,
      ),
    ];
  }

  // Find a mock request by ID
  ServiceRequestModel _findMockRequestById(String requestId) {
    final user = _auth.currentUser;
    final mockRequests = _getMockRequests(user?.uid ?? '');
    return mockRequests.firstWhere(
      (request) => request.id == requestId,
      orElse: () => mockRequests.first,
    );
  }
}
