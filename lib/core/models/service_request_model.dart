import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> categoryIds;
  final bool isUrgent;
  final bool inClientLocation;
  final String? address;
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
      createdAt: DateTime.now(),
      scheduledDate: scheduledDate,
      photos: photos,
      status: 'pending',
    );
  }

  // Convert from Firestore
  factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      isUrgent: data['isUrgent'] ?? false,
      inClientLocation: data['inClientLocation'] ?? true,
      address: data['address'],
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
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      proposalCount: proposalCount ?? this.proposalCount,
    );
  }
}
