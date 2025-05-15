// lib/presentation/screens/chat/components/confirmation_message_bubble.dart
import 'package:flutter/material.dart';

class ConfirmationMessageBubble extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final bool hasResponded;

  const ConfirmationMessageBubble({
    Key? key,
    required this.message,
    required this.onConfirm,
    required this.onReject,
    this.hasResponded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y mensaje
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Mostrar botones solo si no se ha respondido
          if (!hasResponded) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón rechazar
                OutlinedButton(
                  onPressed: onReject,
                  child: Text('NO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size(60, 36),
                  ),
                ),
                SizedBox(width: 8),
                // Botón confirmar
                ElevatedButton(
                  onPressed: onConfirm,
                  child: Text('SÍ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size(60, 36),
                  ),
                ),
              ],
            ),
          ],

          // Si ya se respondió, mostrar el resultado
          if (hasResponded)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "✅ Trabajo confirmado como completado",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
