// lib/presentation/screens/technician/requests/components/empty_requests_view.dart
import 'package:flutter/material.dart';

class EmptyRequestsView extends StatelessWidget {
  final String message;

  const EmptyRequestsView({
    Key? key,
    this.message = 'No hay solicitudes disponibles',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
