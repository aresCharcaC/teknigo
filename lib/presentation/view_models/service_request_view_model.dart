// lib/presentation/view_models/service_request_view_model.dart
import 'dart:io';
import 'dart:async';
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

  // Stream subscription for real-time updates
  Stream<List<ServiceRequestModel>>? _requestsStream;
  StreamSubscription? _requestsSubscription;

  // Constructor to start listener
  ServiceRequestViewModel() {
    print("ServiceRequestViewModel initialized");
    // Start real-time listener if there's an authenticated user
    if (_auth.currentUser != null) {
      _startRequestsListener();
    }

    // Listen for auth state changes to restart the listener if needed
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _startRequestsListener();
      } else {
        // Cancel subscription if user logs out
        _cancelSubscription();
        _userRequests = [];
        notifyListeners();
      }
    });
  }

  // Cancel current subscription if exists
  void _cancelSubscription() {
    print("Canceling subscription");
    if (_requestsSubscription != null) {
      _requestsSubscription!.cancel();
      _requestsSubscription = null;
    }
  }

  // Start real-time listener
  void _startRequestsListener() {
    try {
      print("Starting requests listener");
      // Cancel existing subscription if any
      _cancelSubscription();

      // Get the stream
      _requestsStream = _repository.getUserRequestsStream();

      // Subscribe to the stream
      _requestsSubscription = _requestsStream?.listen(
        (requests) {
          print("Stream update received: ${requests.length} requests");
          _userRequests = requests;
          setLoaded(); // Ensure the loading state is updated
          notifyListeners();
        },
        onError: (error) {
          print('Error in service requests stream: $error');
          setError('Error al cargar solicitudes: $error');
        },
      );

      print("Requests listener started");
    } catch (e) {
      print('Error starting requests listener: $e');
      setError('Error al iniciar escucha de solicitudes: $e');
    }
  }

  // Explicitly reload requests - call this when returning to the screen
  Future<void> reloadRequests() async {
    print("Reloading requests explicitly");
    setLoading();

    try {
      // First try to get requests once
      final requests = await _repository.getUserRequests();
      _userRequests = requests;

      // Then restart the listener for real-time updates
      _startRequestsListener();

      setLoaded();
    } catch (e) {
      print('Error reloading requests: $e');
      setError('Error al recargar solicitudes: $e');
    }
  }

  // Load user's service requests (initial load)
  Future<void> loadUserServiceRequests() async {
    print("Loading user service requests");
    return executeAsync<void>(() async {
      final user = _auth.currentUser;
      if (user == null) {
        print('No authenticated user to load requests');
        return;
      }

      // Get requests from Firebase
      final requests = await _repository.getUserRequests();

      // Check if requests were obtained
      _userRequests = requests;
      print('Successfully loaded ${_userRequests.length} requests');

      // Start real-time listener if not already started
      if (_requestsSubscription == null) {
        _startRequestsListener();
      }
    });
  }

  // Get a specific service request by ID
  Future<void> getServiceRequestById(String requestId) async {
    print("Getting request by ID: $requestId");
    return executeAsync<void>(() async {
      // First check if it's already in the loaded requests
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

      // If not found locally or it's an empty request, query Firebase
      if (_currentRequest!.id.isEmpty) {
        final request = await _repository.getRequestById(requestId);
        if (request != null) {
          _currentRequest = request;
          print('Request loaded from Firebase: ${request.id}');
        } else {
          print('Request not found in Firebase: $requestId');
          setError('Request not found');
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
      print("Creating service request");
      setLoading();

      final user = _auth.currentUser;
      if (user == null) {
        setError('Usuario no autenticado');
        return Resource.error('Usuario no autenticado');
      }

      // Create a request with the current user ID
      final newRequest = request.copyWith(userId: user.uid);

      // Send to repository with photos
      final requestId = await _repository.createServiceRequest(
        newRequest,
        photos,
      );

      if (requestId != null) {
        // Add to local list (although the stream should update it soon)
        final createdRequest = newRequest.copyWith(id: requestId);
        _userRequests = [createdRequest, ..._userRequests];
        notifyListeners();

        // Explicitly reload to ensure we get the latest data
        _reloadAfterDelay();

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

  // Helper to reload data after a short delay
  Future<void> _reloadAfterDelay() async {
    // Wait a short time to allow Firestore to update
    await Future.delayed(const Duration(milliseconds: 1000));
    loadUserServiceRequests();
  }

  // Delete a service request completely (including photos)
  Future<Resource<bool>> deleteServiceRequest(String requestId) async {
    try {
      print("Deleting service request: $requestId");
      setLoading();

      final user = _auth.currentUser;
      if (user == null) {
        setError('Usuario no autenticado');
        return Resource.error('Usuario no autenticado');
      }

      // Send to repository for complete deletion
      final success = await _repository.deleteRequest(requestId);

      if (success) {
        print("Delete request successful, updating local data");
        // Remove from local list
        _userRequests.removeWhere((request) => request.id == requestId);

        // Clear current request if it's the one being deleted
        if (_currentRequest != null && _currentRequest!.id == requestId) {
          _currentRequest = null;
        }

        notifyListeners();

        // Explicitly reload after a short delay to ensure we get the latest data
        _reloadAfterDelay();

        setLoaded();
        return Resource.success(true);
      } else {
        setError('Error al eliminar la solicitud');
        return Resource.error('Error al eliminar la solicitud');
      }
    } catch (e) {
      final errorMsg = 'Error al eliminar solicitud: $e';
      setError(errorMsg);
      return Resource.error(errorMsg);
    }
  }

  @override
  void dispose() {
    // Clean up resources when destroying the ViewModel
    print("ServiceRequestViewModel disposed");
    _cancelSubscription();
    super.dispose();
  }
}
