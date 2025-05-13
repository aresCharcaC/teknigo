// lib/presentation/screens/technician/requests/components/proposal_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/models/proposal_model.dart';
import '../../../../view_models/proposal_view_model.dart';
import '../../../chat/chat_detail_screen.dart';

class ProposalForm extends StatefulWidget {
  final String requestId;
  final String clientId;
  final VoidCallback onClose;

  const ProposalForm({
    Key? key,
    required this.requestId,
    required this.clientId,
    required this.onClose,
  }) : super(key: key);

  @override
  _ProposalFormState createState() => _ProposalFormState();
}

class _ProposalFormState extends State<ProposalForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();

  String _availability = 'Hoy mismo';
  bool _isLoading = false;

  final List<String> _availabilityOptions = [
    'Hoy mismo',
    'Mañana',
    'En los próximos días',
    'A coordinar',
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enviar propuesta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Precio aproximado
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Precio aproximado (S/)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Disponibilidad
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Disponibilidad',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                value: _availability,
                items:
                    _availabilityOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _availability = newValue;
                    });
                  }
                },
              ),

              SizedBox(height: 16),

              // Mensaje breve
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Mensaje breve',
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                  hintText:
                      'Ejemplo: Puedo solucionar tu problema, tengo experiencia en este tipo de trabajos.',
                ),
                maxLines: 3,
                maxLength: 150,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un mensaje';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : widget.onClose,
                      child: Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendProposal,
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text('Enviar propuesta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendProposal() async {
    if (!_formKey.currentState!.validate()) return;

    // Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });

    try {
      // Crear el modelo de propuesta
      final proposal = ProposalModel(
        price: double.parse(_priceController.text),
        availability: _availability,
        message: _messageController.text,
      );

      // Enviar la propuesta
      final viewModel = Provider.of<ProposalViewModel>(context, listen: false);

      final result = await viewModel.sendProposal(
        requestId: widget.requestId,
        clientId: widget.clientId,
        proposal: proposal,
      );

      // Si hay éxito, cerrar y navegar al chat
      if (result.isSuccess && mounted) {
        final chatId = result.data;

        // Cerrar el modal
        widget.onClose();

        // Navegar al chat si se creó
        if (chatId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(chatId: chatId),
            ),
          );

          // Opcional: mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Propuesta enviada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Error al enviar propuesta'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Manejar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar propuesta: $e'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
