// lib/presentation/screens/technician/profile/components/rating_section.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../widgets/star_rating.dart';

class RatingSection extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool isEditing;

  const RatingSection({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No mostrar nada en modo edición
    if (isEditing) return const SizedBox.shrink();

    // Para técnicos sin calificaciones
    if (reviewCount == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "Sin calificaciones aún",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calificaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Calificación promedio con estrellas
            Row(
              children: [
                // Número grande
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 16),

                // Estrellas y contador de reseñas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarRating(rating: rating, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '$reviewCount ${reviewCount == 1 ? 'calificación' : 'calificaciones'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
