import 'package:flutter/material.dart';
import '../../core/models/pending_confirmation_model.dart';

class ConfirmationDialog extends StatelessWidget {
  final PendingConfirmationModel confirmation;
  final Function(bool) onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.confirmation,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Evitar que se cierre con el botón atrás
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text('Confirmación de Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El técnico ha marcado el siguiente servicio como completado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Información del servicio
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    confirmation.serviceTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '¿Confirmas que el trabajo ha sido completado correctamente?',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text(
              'Debes confirmar si el trabajo está terminado para continuar.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          // Botón de rechazar
          OutlinedButton.icon(
            onPressed: () => onConfirm(false),
            icon: Icon(Icons.close, color: Colors.red),
            label: Text('NO, FALTA TRABAJO'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
            ),
          ),

          // Botón de confirmar
          ElevatedButton.icon(
            onPressed: () => onConfirm(true),
            icon: Icon(Icons.check),
            label: Text('SÍ, ESTÁ COMPLETADO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
