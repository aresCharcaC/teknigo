// lib/presentation/screens/chat/components/price_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PriceConfirmationDialog extends StatefulWidget {
  final double proposedPrice;
  final Function(double) onConfirm;

  const PriceConfirmationDialog({
    Key? key,
    required this.proposedPrice,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _PriceConfirmationDialogState createState() =>
      _PriceConfirmationDialogState();
}

class _PriceConfirmationDialogState extends State<PriceConfirmationDialog> {
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.proposedPrice.toString(),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmar precio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Estás a punto de aceptar este servicio. Por favor confirma el precio acordado:',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Precio (S/)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () {
            try {
              final price = double.parse(_priceController.text);
              if (price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El precio debe ser mayor a cero')),
                );
                return;
              }
              widget.onConfirm(price);
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ingresa un precio válido')),
              );
            }
          },
          child: Text('CONFIRMAR'),
        ),
      ],
    );
  }
}
