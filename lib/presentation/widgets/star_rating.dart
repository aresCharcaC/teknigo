// lib/presentation/widgets/star_rating.dart
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showText;
  final bool interactive;
  final Function(double)? onRatingChanged;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 24,
    this.showText = false,
    this.interactive = false,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Estrellas
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap:
                  interactive ? () => onRatingChanged?.call(index + 1) : null,
              child: Icon(
                index < rating.floor()
                    ? Icons.star
                    : index < rating
                    ? Icons.star_half
                    : Icons.star_border,
                color: Colors.amber,
                size: size,
              ),
            );
          }),
        ),

        // Texto opcional
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: size * 0.7),
          ),
        ],
      ],
    );
  }
}
