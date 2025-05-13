// lib/presentation/screens/technician/requests/components/action_buttons.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/proposal_view_model.dart';
import 'proposal_form.dart';

class ActionButtons extends StatelessWidget {
  final String requestId;
  final String clientId;
  final VoidCallback onNotInterested;

  const ActionButtons({
    Key? key,
    required this.requestId,
    required this.clientId,
    required this.onNotInterested,
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
                      // lib/presentation/screens/technician/requests/components/action_buttons.dart (actualizado - continuación)
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
                    onPressed: () => _showProposalForm(context),
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

  // Mostrar el formulario de propuesta
  void _showProposalForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ChangeNotifierProvider(
            create: (_) => ProposalViewModel(),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ProposalForm(
                requestId: requestId,
                clientId: clientId,
                onClose: () => Navigator.pop(context),
              ),
            ),
          ),
    );
  }
}
