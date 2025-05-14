// lib/presentation/screens/chat/components/proposal_message.dart
import 'package:flutter/material.dart';

class ProposalMessage extends StatelessWidget {
  final String message;
  final double price;
  final String availability;

  const ProposalMessage({
    Key? key,
    required this.message,
    required this.price,
    required this.availability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la propuesta
          Row(
            mainAxisSize: MainAxisSize.min, // Fix overflow
            children: [
              Icon(Icons.local_offer, size: 16, color: Colors.green),
              SizedBox(width: 4),
              Text(
                'Propuesta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          Divider(height: 16),

          // Precio - arreglado para evitar overflow
          Wrap(
            children: [
              Text(
                'Precio aproximado: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'S/ ${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          // Disponibilidad - arreglado para evitar overflow
          Wrap(
            children: [
              Text(
                'Disponibilidad: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(availability),
            ],
          ),

          SizedBox(height: 8),

          // Mensaje
          Text(message),
        ],
      ),
    );
  }
}
