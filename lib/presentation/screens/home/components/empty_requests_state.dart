// lib/presentation/screens/home/components/empty_requests_state.dart
import 'package:flutter/material.dart';

/// Widget para mostrar cuando no hay solicitudes de servicio
class EmptyRequestsState extends StatelessWidget {
  const EmptyRequestsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, size: 48, color: Colors.grey.shade400),
            ),

            const SizedBox(height: 24),

            Text(
              'No tienes solicitudes recientes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            Text(
              'Crea tu primera solicitud para encontrar técnicos especializados cerca de ti',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () => _scrollToRequestForm(context),
              icon: const Icon(Icons.add),
              label: const Text(
                'Crear solicitud',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tips adicionales
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Consejos para tu primera solicitud:',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Describe el problema con detalle\n'
                    '• Selecciona la categoría correcta\n'
                    '• Agrega fotos si es posible\n'
                    '• Marca como urgente si necesitas ayuda hoy',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToRequestForm(BuildContext context) {
    try {
      // Buscar el ScrollController en el contexto padre
      final scrollable = Scrollable.of(context);
      if (scrollable != null) {
        // Hacer scroll hacia arriba (donde está el formulario)
        scrollable.position.animateTo(
          0.0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        // Si no hay ScrollController disponible, mostrar mensaje informativo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El formulario está arriba en esta pantalla'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // En caso de error, mostrar mensaje alternativo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desplázate hacia arriba para crear una solicitud'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
