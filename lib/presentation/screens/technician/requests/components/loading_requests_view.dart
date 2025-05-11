// lib/presentation/screens/technician/requests/components/loading_requests_view.dart
import 'package:flutter/material.dart';

class LoadingRequestsView extends StatelessWidget {
  const LoadingRequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando solicitudes...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
