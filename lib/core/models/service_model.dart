import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceStatus {
  pending, // Solicitud pendiente
  offered, // Oferta enviada al cliente
  accepted, // Oferta aceptada, servicio en curso
  inProgress, // Técnico trabajando
  completed, // Servicio completado
  rated, // Servicio completado y calificado
  cancelled, // Servicio cancelado
  rejected, // Oferta rechazada
}

enum ServiceType {
  immediate, // Servicio inmediato
  scheduled, // Servicio programado
}

enum ServiceLocation {
  clientHome, // A domicilio
  techOffice, // En local del técnico
}

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
  });

  // Constructor desde un mapa (para convertir desde Firestore)
  factory ServiceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceModel(
      id: documentId,
      clientId: map['clientId'] ?? '',
      technicianId: map['technicianId'],
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString() == 'ServiceStatus.${map['status']}',
        orElse: () => ServiceStatus.pending,
      ),
      type: ServiceType.values.firstWhere(
        (e) => e.toString() == 'ServiceType.${map['type']}',
        orElse: () => ServiceType.immediate,
      ),
      location: ServiceLocation.values.firstWhere(
        (e) => e.toString() == 'ServiceLocation.${map['location']}',
        orElse: () => ServiceLocation.clientHome,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate(),
      clientLocation: map['clientLocation'],
      clientAddress: map['clientAddress'] ?? '',
      photos: map['photos'] != null ? List<String>.from(map['photos']) : null,
      price: (map['price'] as num?)?.toDouble(),
      notes: map['notes'],
      clientRating: (map['clientRating'] as num?)?.toDouble(),
      clientReview: map['clientReview'],
      technicianRating: (map['technicianRating'] as num?)?.toDouble(),
      technicianReview: map['technicianReview'],
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      cancellationReason: map['cancellationReason'],
    );
  }

  // Convertir a un mapa (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'technicianId': technicianId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'status':
          status.toString().split('.').last, // Guardar solo el nombre del enum
      'type': type.toString().split('.').last,
      'location': location.toString().split('.').last,
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
    };
  }

  // Crear una copia del modelo con algunos campos modificados
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
    );
  }

  // Verificar si el servicio está activo
  bool get isActive {
    return status == ServiceStatus.pending ||
        status == ServiceStatus.offered ||
        status == ServiceStatus.accepted ||
        status == ServiceStatus.inProgress;
  }

  // Verificar si el servicio está finalizado (completado o cancelado)
  bool get isFinished {
    return status == ServiceStatus.completed ||
        status == ServiceStatus.rated ||
        status == ServiceStatus.cancelled ||
        status == ServiceStatus.rejected;
  }
}
