// lib/data/repositories/service_request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/models/service_request_model.dart';

class ServiceRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection name for service requests - using a constant for consistency
  final String _collectionName = 'service_requests';

  // Create a new service request
  Future<String?> createServiceRequest(
    ServiceRequestModel request,
    List<File>? photos,
  ) async {
    try {
      print("Repository: Creating service request");
      // Get current user
      final user = _auth.currentUser;
      if (user == null) {
        print("Repository: No authenticated user");
        return null;
      }

      // Prepare base data for the request
      Map<String, dynamic> requestData = request.toFirestore();

      // Make sure the user ID is correct
      requestData['userId'] = user.uid;

      // If there are photos, upload them first
      if (photos != null && photos.isNotEmpty) {
        print("Repository: Uploading ${photos.length} photos");
        final photoUrls = await _uploadPhotos(user.uid, photos);
        if (photoUrls.isNotEmpty) {
          requestData['photos'] = photoUrls;
        }
      }

      // Create the request in Firestore
      final docRef = await _firestore
          .collection(_collectionName)
          .add(requestData);
      print('Repository: Request created with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Repository: Error creating request: $e');
      return null;
    }
  }

  // Upload photos to Storage
  Future<List<String>> _uploadPhotos(String userId, List<File> photos) async {
    List<String> photoUrls = [];

    try {
      for (var i = 0; i < photos.length; i++) {
        final file = photos[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path =
            '${AppConstants.serviceImagesPath}/$userId/$timestamp-$i.jpg';

        // Upload file
        final uploadTask = _storage.ref().child(path).putFile(file);

        // Show progress if needed
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print(
            'Repository: Upload progress $i: ${(progress * 100).toStringAsFixed(2)}%',
          );
        });

        // Wait for upload to complete
        final snapshot = await uploadTask;

        // Get URL
        final url = await snapshot.ref.getDownloadURL();
        photoUrls.add(url);

        print('Repository: Photo $i uploaded successfully: $url');
      }
    } catch (e) {
      print('Repository: Error uploading photos: $e');
    }

    return photoUrls;
  }

  // Get current user's requests
  Future<List<ServiceRequestModel>> getUserRequests() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Repository: No authenticated user to get requests');
        return [];
      }

      print('Repository: Getting requests for user: ${user.uid}');

      // Modified to avoid needing a composite index
      // We only filter by userId and don't use orderBy
      final snapshot =
          await _firestore
              .collection(_collectionName)
              .where('userId', isEqualTo: user.uid)
              .get();

      print('Repository: Requests found: ${snapshot.docs.length}');

      final requests =
          snapshot.docs
              .map((doc) {
                try {
                  return ServiceRequestModel.fromFirestore(doc);
                } catch (e) {
                  print('Repository: Error converting document ${doc.id}: $e');
                  return null;
                }
              })
              .where((request) => request != null)
              .cast<ServiceRequestModel>()
              .toList();

      // Sort manually in-memory to avoid needing the index
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('Repository: Requests processed successfully: ${requests.length}');
      return requests;
    } catch (e) {
      print('Repository: Error getting user requests: $e');
      return [];
    }
  }

  // Listen for changes in user's requests (real-time)
  Stream<List<ServiceRequestModel>> getUserRequestsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      print('Repository: No authenticated user for stream');
      return Stream.value([]);
    }

    print('Repository: Setting up request stream for user: ${user.uid}');

    // Modified to avoid needing a composite index
    // Just filter by userId without orderBy
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          print(
            'Repository: Stream update - ${snapshot.docs.length} documents',
          );
          final requests =
              snapshot.docs
                  .map((doc) {
                    try {
                      return ServiceRequestModel.fromFirestore(doc);
                    } catch (e) {
                      print(
                        'Repository: Error converting document in stream ${doc.id}: $e',
                      );
                      return null;
                    }
                  })
                  .where((request) => request != null)
                  .cast<ServiceRequestModel>()
                  .toList();

          // Sort manually in memory
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return requests;
        });
  }

  // Delete a request completely - including all photos
  Future<bool> deleteRequest(String requestId) async {
    try {
      print('Repository: Deleting request completely: $requestId');

      // First, get the request to see if it has photos
      final doc =
          await _firestore.collection(_collectionName).doc(requestId).get();
      if (!doc.exists) {
        print('Repository: Request does not exist: $requestId');
        return false;
      }

      final data = doc.data();
      if (data == null) {
        print('Repository: Request data is null: $requestId');
        return false;
      }

      // Check if the request has photos and delete them
      if (data.containsKey('photos') && data['photos'] is List) {
        final photos = List<String>.from(data['photos']);
        for (var photoUrl in photos) {
          try {
            // Delete from Firebase Storage
            await _storage.refFromURL(photoUrl).delete();
            print('Repository: Deleted photo: $photoUrl');
          } catch (e) {
            print('Repository: Error deleting photo: $e');
            // Continue even if photo deletion fails
          }
        }
      }

      // Now delete the document from Firestore
      await _firestore.collection(_collectionName).doc(requestId).delete();
      print('Repository: Request deleted successfully: $requestId');
      return true;
    } catch (e) {
      print('Repository: Error deleting request: $e');
      return false;
    }
  }

  // Get a specific request
  Future<ServiceRequestModel?> getRequestById(String requestId) async {
    try {
      print('Repository: Getting request by ID: $requestId');
      final doc =
          await _firestore.collection(_collectionName).doc(requestId).get();

      if (doc.exists) {
        print('Repository: Request found: $requestId');
        return ServiceRequestModel.fromFirestore(doc);
      }
      print('Repository: Request not found: $requestId');
      return null;
    } catch (e) {
      print('Repository: Error getting request: $e');
      return null;
    }
  }
}
