// lib/core/models/service_model.dart (update the model)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/service_enums.dart';

class ServiceModel {
  final String id;
  final String clientId;
  final String? technicianId;
  final String categoryId;
  final String title;
  final String description;
  final ServiceStatus status;
  final ServiceType type;
  final ServiceLocation location;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final GeoPoint? clientLocation;
  final String clientAddress;
  final List<String>? photos;
  final double? price;
  final String? notes;
  final double? clientRating;
  final String? clientReview;
  final double? technicianRating;
  final String? technicianReview;
  final DateTime? completedAt;
  final String? cancellationReason;
  final String chatId; // New field for chat reference

  // New fields
  final DateTime? acceptedAt;
  final DateTime? inProgressAt;
  final DateTime? finishedAt;
  final double? agreedPrice;

  ServiceModel({
    required this.id,
    required this.clientId,
    this.technicianId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.status,
    required this.type,
    required this.location,
    required this.createdAt,
    this.scheduledDate,
    this.clientLocation,
    required this.clientAddress,
    this.photos,
    this.price,
    this.notes,
    this.clientRating,
    this.clientReview,
    this.technicianRating,
    this.technicianReview,
    this.completedAt,
    this.cancellationReason,
    // New fields
    this.acceptedAt,
    this.inProgressAt,
    this.finishedAt,
    this.agreedPrice,
    this.chatId = '', // Default empty string
  });

  // Constructor from a map (for conversion from Firestore)
  factory ServiceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceModel(
      id: documentId,
      clientId: map['clientId'] ?? '',
      technicianId: map['technicianId'],
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: ServiceStatusExtension.fromString(map['status'] ?? ''),
      type: ServiceTypeExtension.fromString(map['type'] ?? ''),
      location: ServiceLocationExtension.fromString(map['location'] ?? ''),
      createdAt: _parseTimestamp(map['createdAt']),
      scheduledDate: _parseTimestamp(map['scheduledDate']),
      clientLocation: map['clientLocation'],
      clientAddress: map['clientAddress'] ?? '',
      photos: _parseStringList(map['photos']),
      price: (map['price'] as num?)?.toDouble(),
      notes: map['notes'],
      clientRating: (map['clientRating'] as num?)?.toDouble(),
      clientReview: map['clientReview'],
      technicianRating: (map['technicianRating'] as num?)?.toDouble(),
      technicianReview: map['technicianReview'],
      completedAt: _parseTimestamp(map['completedAt']),
      cancellationReason: map['cancellationReason'],
      // New fields
      acceptedAt: _parseTimestamp(map['acceptedAt']),
      inProgressAt: _parseTimestamp(map['inProgressAt']),
      finishedAt: _parseTimestamp(map['finishedAt']),
      agreedPrice: (map['agreedPrice'] as num?)?.toDouble(),
      chatId: map['chatId'] ?? '', // Add the chatId from the map
    );
  }

  // Helper methods for parsing
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.now();
  }

  static List<String>? _parseStringList(dynamic list) {
    if (list == null) return null;
    return (list as List).map((item) => item.toString()).toList();
  }

  // Convert to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'technicianId': technicianId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'status': status.value,
      'type': type.value,
      'location': location.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledDate':
          scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'clientLocation': clientLocation,
      'clientAddress': clientAddress,
      'photos': photos,
      'price': price,
      'notes': notes,
      'clientRating': clientRating,
      'clientReview': clientReview,
      'technicianRating': technicianRating,
      'technicianReview': technicianReview,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancellationReason': cancellationReason,
      // New fields
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'inProgressAt':
          inProgressAt != null ? Timestamp.fromDate(inProgressAt!) : null,
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      'agreedPrice': agreedPrice,
      'chatId': chatId, // Include chatId in the map
    };
  }

  // Create a copy of the model with some fields modified
  ServiceModel copyWith({
    String? technicianId,
    ServiceStatus? status,
    DateTime? scheduledDate,
    double? price,
    String? notes,
    double? clientRating,
    String? clientReview,
    double? technicianRating,
    String? technicianReview,
    DateTime? completedAt,
    String? cancellationReason,
    // New fields
    DateTime? acceptedAt,
    DateTime? inProgressAt,
    DateTime? finishedAt,
    double? agreedPrice,
    String? chatId,
  }) {
    return ServiceModel(
      id: this.id,
      clientId: this.clientId,
      technicianId: technicianId ?? this.technicianId,
      categoryId: this.categoryId,
      title: this.title,
      description: this.description,
      status: status ?? this.status,
      type: this.type,
      location: this.location,
      createdAt: this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      clientLocation: this.clientLocation,
      clientAddress: this.clientAddress,
      photos: this.photos,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      clientRating: clientRating ?? this.clientRating,
      clientReview: clientReview ?? this.clientReview,
      technicianRating: technicianRating ?? this.technicianRating,
      technicianReview: technicianReview ?? this.technicianReview,
      completedAt: completedAt ?? this.completedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      // New fields
      acceptedAt: acceptedAt ?? this.acceptedAt,
      inProgressAt: inProgressAt ?? this.inProgressAt,
      finishedAt: finishedAt ?? this.finishedAt,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      chatId: chatId ?? this.chatId,
    );
  }

  // Getters to check status
  bool get isActive => [
    ServiceStatus.pending,
    ServiceStatus.offered,
    ServiceStatus.accepted,
    ServiceStatus.inProgress,
  ].contains(status);

  bool get isFinished => [
    ServiceStatus.completed,
    ServiceStatus.rated,
    ServiceStatus.cancelled,
    ServiceStatus.rejected,
  ].contains(status);
}
