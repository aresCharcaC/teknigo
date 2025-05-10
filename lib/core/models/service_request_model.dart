import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceRequestModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> categoryIds;
  final bool isUrgent;
  final bool inClientLocation;
  final String? address;
  final LatLng? location; // Campo para coordenadas
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final List<String>? photos;
  final String status; // pending, accepted, completed, cancelled
  final int proposalCount; // Number of technician proposals

  ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.categoryIds,
    required this.isUrgent,
    required this.inClientLocation,
    this.address,
    this.location,
    required this.createdAt,
    this.scheduledDate,
    this.photos,
    required this.status,
    this.proposalCount = 0,
  });

  // For creating a new request
  factory ServiceRequestModel.create({
    required String userId,
    required String title,
    required String description,
    required List<String> categoryIds,
    required bool isUrgent,
    required bool inClientLocation,
    String? address,
    LatLng? location,
    DateTime? scheduledDate,
    List<String>? photos,
  }) {
    return ServiceRequestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      userId: userId,
      title: title,
      description: description,
      categoryIds: categoryIds,
      isUrgent: isUrgent,
      inClientLocation: inClientLocation,
      address: address,
      location: location,
      createdAt: DateTime.now(),
      scheduledDate: scheduledDate,
      photos: photos,
      status: 'pending',
    );
  }

  // Convert from Firestore
  factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Extraer coordenadas si existen
    LatLng? location;
    if (data['location'] != null) {
      final GeoPoint? geoPoint =
          data['location'] is GeoPoint ? data['location'] as GeoPoint : null;

      if (geoPoint != null) {
        location = LatLng(geoPoint.latitude, geoPoint.longitude);
      } else if (data['location'] is Map) {
        // Si location es un mapa con lat/lng
        final locationMap = data['location'] as Map;
        if (locationMap.containsKey('latitude') &&
            locationMap.containsKey('longitude')) {
          final lat = (locationMap['latitude'] as num).toDouble();
          final lng = (locationMap['longitude'] as num).toDouble();
          location = LatLng(lat, lng);
        }
      }
    }

    return ServiceRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      isUrgent: data['isUrgent'] ?? false,
      inClientLocation: data['inClientLocation'] ?? true,
      address: data['address'],
      location: location,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledDate:
          data['scheduledDate'] != null
              ? (data['scheduledDate'] as Timestamp).toDate()
              : null,
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
      status: data['status'] ?? 'pending',
      proposalCount: data['proposalCount'] ?? 0,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'categoryIds': categoryIds,
      'isUrgent': isUrgent,
      'inClientLocation': inClientLocation,
      'address': address,
      'location':
          location != null
              ? GeoPoint(location!.latitude, location!.longitude)
              : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledDate':
          scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'photos': photos,
      'status': status,
      'proposalCount': proposalCount,
    };
  }

  // Create a copy with updated fields
  ServiceRequestModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? categoryIds,
    bool? isUrgent,
    bool? inClientLocation,
    String? address,
    LatLng? location,
    DateTime? createdAt,
    DateTime? scheduledDate,
    List<String>? photos,
    String? status,
    int? proposalCount,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryIds: categoryIds ?? this.categoryIds,
      isUrgent: isUrgent ?? this.isUrgent,
      inClientLocation: inClientLocation ?? this.inClientLocation,
      address: address ?? this.address,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      proposalCount: proposalCount ?? this.proposalCount,
    );
  }
}
