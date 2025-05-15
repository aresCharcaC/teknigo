// lib/presentation/screens/chat/components/service_rating_dialog.dart

import 'package:flutter/material.dart';

class ServiceRatingDialog extends StatefulWidget {
  final Function(double rating, String? comment) onSubmit;

  const ServiceRatingDialog({Key? key, required this.onSubmit})
    : super(key: key);

  @override
  State<ServiceRatingDialog> createState() => _ServiceRatingDialogState();
}

class _ServiceRatingDialogState extends State<ServiceRatingDialog> {
  double _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Califica el servicio'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Por favor, califica la calidad del servicio recibido:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Stars for rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 8),
            Text(
              _getRatingText(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Field for comments (optional)
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentarios (opcional)',
                hintText: 'Escribe tu opinión sobre el servicio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed:
              _rating == 0
                  ? null
                  : () => widget.onSubmit(
                    _rating,
                    _commentController.text.isEmpty
                        ? null
                        : _commentController.text,
                  ),
          child: const Text('ENVIAR'),
        ),
      ],
    );
  }

  String _getRatingText() {
    if (_rating == 0) return 'Selecciona una calificación';
    if (_rating == 1) return 'Malo';
    if (_rating == 2) return 'Regular';
    if (_rating == 3) return 'Bueno';
    if (_rating == 4) return 'Muy bueno';
    return 'Excelente';
  }
}
