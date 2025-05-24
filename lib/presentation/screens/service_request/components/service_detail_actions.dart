// lib/presentation/screens/service_request/components/service_detail_actions.dart - TOTALMENTE CORREGIDO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/service_request_view_model.dart';
import '../edit_service_request_screen.dart';

class ServiceDetailActions extends StatefulWidget {
  final ServiceRequestModel request;

  const ServiceDetailActions({Key? key, required this.request})
    : super(key: key);

  @override
  _ServiceDetailActionsState createState() => _ServiceDetailActionsState();
}

class _ServiceDetailActionsState extends State<ServiceDetailActions> {
  bool _isDisposed = false;
  ScaffoldMessengerState? _scaffoldMessenger;
  ServiceRequestViewModel? _requestViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // GUARDAR REFERENCIAS SEGURAS
    if (!_isDisposed && mounted) {
      try {
        _scaffoldMessenger = ScaffoldMessenger.of(context);
        _requestViewModel = Provider.of<ServiceRequestViewModel>(
          context,
          listen: false,
        );
      } catch (e) {
        print('Error obteniendo referencias en ServiceDetailActions: $e');
      }
    }
  }

  @override
  void dispose() {
    print('ServiceDetailActions dispose()');
    _isDisposed = true;
    _scaffoldMessenger = null;
    _requestViewModel = null;
    super.dispose();
  }

  // MÉTODO SEGURO PARA MOSTRAR SNACKBAR
  void _showSafeSnackBar(String message, {Color? backgroundColor}) {
    final messenger = _scaffoldMessenger;
    if (messenger != null && !_isDisposed) {
      try {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        print('Error mostrando SnackBar en ServiceDetailActions: $e');
      }
    }
  }

  // MÉTODO SEGURO PARA MOSTRAR DIALOGO
  Future<bool?> _showSafeDialog(Widget dialog) async {
    if (!_isDisposed && mounted) {
      try {
        return await showDialog<bool>(
          context: context,
          builder: (context) => dialog,
        );
      } catch (e) {
        print('Error mostrando diálogo: $e');
        return null;
      }
    }
    return null;
  }

  // MÉTODO SEGURO PARA MOSTRAR DIALOGO DE CARGA
  void _showSafeLoadingDialog() {
    if (!_isDisposed && mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      } catch (e) {
        print('Error mostrando diálogo de carga: $e');
      }
    }
  }

  // MÉTODO SEGURO PARA CERRAR DIALOGO
  void _safePopDialog() {
    if (!_isDisposed && mounted && Navigator.canPop(context)) {
      try {
        Navigator.pop(context);
      } catch (e) {
        print('Error cerrando diálogo: $e');
      }
    }
  }

  // MÉTODO SEGURO PARA NAVEGAR
  Future<void> _safeNavigate(Widget destination) async {
    if (!_isDisposed && mounted) {
      try {
        final result = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );

        // Manejar resultado de navegación
        if (result == true && !_isDisposed) {
          _showSafeSnackBar(
            '✅ Solicitud actualizada correctamente',
            backgroundColor: Colors.green,
          );

          // Actualizar la vista actual
          final requestViewModel = _requestViewModel;
          if (requestViewModel != null) {
            requestViewModel.getServiceRequestById(widget.request.id);
          }
        }
      } catch (e) {
        print('Error navegando: $e');
        if (!_isDisposed) {
          _showSafeSnackBar(
            'Error de navegación: $e',
            backgroundColor: Colors.red,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    // Solo mostrar acciones si el estado permite interacción
    final canEdit = widget.request.status == 'pending';
    final canCancel = ['pending', 'offered'].contains(widget.request.status);

    if (!canEdit && !canCancel) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Botón Editar
                if (canEdit) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isDisposed ? null : () => _editRequest(),
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Editar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  if (canCancel) const SizedBox(width: 12),
                ],

                // Botón Cancelar/Eliminar
                if (canCancel) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDisposed ? null : () => _confirmCancel(),
                      icon: const Icon(Icons.cancel),
                      label: Text(
                        widget.request.status == 'pending'
                            ? 'Eliminar'
                            : 'Cancelar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getActionInfoText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getActionInfoText() {
    if (widget.request.status == 'pending') {
      return 'Puedes editar o eliminar esta solicitud mientras no haya propuestas.';
    } else if (widget.request.status == 'offered') {
      return 'Ya hay propuestas para esta solicitud. Solo puedes cancelarla.';
    }
    return '';
  }

  void _editRequest() {
    if (_isDisposed) return;
    _safeNavigate(EditServiceRequestScreen(request: widget.request));
  }

  void _confirmCancel() {
    if (_isDisposed) return;

    final actionText =
        widget.request.status == 'pending' ? 'eliminar' : 'cancelar';
    final actionTextCaps =
        widget.request.status == 'pending' ? 'ELIMINAR' : 'CANCELAR';

    _showSafeDialog(
      AlertDialog(
        title: Text(
          '${actionTextCaps.toLowerCase().capitalizeFirst()} solicitud',
        ),
        content: Text(
          '¿Estás seguro de que deseas $actionText esta solicitud?${widget.request.status == 'pending' ? ' Esta acción no se puede deshacer.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelRequest();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(actionTextCaps),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest() async {
    if (_isDisposed) return;

    try {
      // Mostrar indicador de carga
      _showSafeLoadingDialog();

      final requestViewModel = _requestViewModel;
      if (requestViewModel == null) {
        throw Exception('ViewModel no disponible');
      }

      final result = await requestViewModel.deleteServiceRequest(
        widget.request.id,
      );

      // Cerrar indicador de carga
      _safePopDialog();

      if (!_isDisposed) {
        if (result.isSuccess) {
          // Mostrar mensaje de éxito
          _showSafeSnackBar(
            widget.request.status == 'pending'
                ? 'Solicitud eliminada correctamente'
                : 'Solicitud cancelada correctamente',
            backgroundColor: Colors.green,
          );

          // Volver a la pantalla anterior de forma segura
          if (mounted && Navigator.canPop(context)) {
            // Usar WidgetsBinding para navegar de forma segura
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_isDisposed && mounted && Navigator.canPop(context)) {
                try {
                  Navigator.pop(context);
                } catch (e) {
                  print('Error navegando de vuelta después de cancelar: $e');
                }
              }
            });
          }
        } else {
          // Mostrar error
          _showSafeSnackBar(
            'Error: ${result.error}',
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de carga en caso de error
      _safePopDialog();

      if (!_isDisposed) {
        _showSafeSnackBar(
          'Error inesperado: $e',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }
}

// Extension para capitalizar primera letra
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
