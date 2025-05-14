// lib/presentation/screens/chat/components/chat_input.dart (CORREGIDO)
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onSendImage;
  final VoidCallback onTakePhoto;
  final VoidCallback onSendLocation;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    required this.onSendImage,
    required this.onTakePhoto,
    required this.onSendLocation,
  }) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textController = TextEditingController();
  bool _showAttachOptions = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opciones de adjuntos (expandible)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _showAttachOptions ? 70 : 0,
            child:
                _showAttachOptions
                    ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildAttachOption(
                            icon: Icons.image,
                            label: 'Galería',
                            color: Colors.green,
                            onTap: () {
                              setState(() => _showAttachOptions = false);
                              widget.onSendImage();
                            },
                          ),
                          _buildAttachOption(
                            icon: Icons.camera_alt,
                            label: 'Cámara',
                            color: Colors.blue,
                            onTap: () {
                              setState(() => _showAttachOptions = false);
                              widget.onTakePhoto();
                            },
                          ),
                          _buildAttachOption(
                            icon: Icons.location_on,
                            label: 'Ubicación',
                            color: Colors.red,
                            onTap: () {
                              setState(() => _showAttachOptions = false);
                              widget.onSendLocation();
                            },
                          ),
                        ],
                      ),
                    )
                    : SizedBox.shrink(),
          ),

          // Barra de entrada de texto - corregida para evitar overflow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end, // Alinear al final
              children: [
                // Botón para mostrar/ocultar opciones de adjuntos
                IconButton(
                  icon: Icon(
                    _showAttachOptions ? Icons.close : Icons.attach_file,
                    color: _showAttachOptions ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showAttachOptions = !_showAttachOptions;
                    });
                  },
                  constraints: BoxConstraints.tightFor(width: 40, height: 40),
                  padding: EdgeInsets.zero,
                ),

                // Campo de texto
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),

                // Botón de enviar
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    _sendMessage(_textController.text);
                  },
                  constraints: BoxConstraints.tightFor(width: 40, height: 40),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construir una opción de adjunto
  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono circular
          InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          // Etiqueta
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Enviar mensaje
  void _sendMessage(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    widget.onSendMessage(trimmedText);
    _textController.clear();
  }
}
