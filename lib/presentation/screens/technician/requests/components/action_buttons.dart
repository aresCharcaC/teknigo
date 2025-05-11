// lib/presentation/screens/technician/requests/components/action_buttons.dart
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onNotInterested;
  final VoidCallback onSendProposal;

  const ActionButtons({
    Key? key,
    required this.onNotInterested,
    required this.onSendProposal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // Botón No me interesa
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNotInterested,
                    icon: const Icon(Icons.close),
                    label: const Text('No me interesa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Botón Enviar propuesta
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSendProposal,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar propuesta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
