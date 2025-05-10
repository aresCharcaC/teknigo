// lib/presentation/screens/home/components/empty_requests_state.dart
import 'package:flutter/material.dart';

/// Widget to display when there are no service requests
class EmptyRequestsState extends StatelessWidget {
  const EmptyRequestsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No tienes solicitudes recientes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea una solicitud para encontrar técnicos',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Scroll to the top of the screen to focus on the request form
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}
