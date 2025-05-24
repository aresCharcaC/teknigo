// lib/presentation/screens/service_request/edit_service_request_screen.dart - CORREGIDO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service_request_model.dart';
import '../../view_models/service_request_view_model.dart';
import '../../view_models/category_view_model.dart';
import 'components_edit/edit_form_data.dart';
import 'components_edit/edit_info_banner.dart';
import 'components_edit/edit_basic_fields.dart';
import 'components_edit/edit_categories_section.dart';
import 'components_edit/edit_urgency_section.dart';
import 'components_edit/edit_location_section.dart';
import 'components_edit/edit_photos_section.dart';
import 'components_edit/edit_submit_button.dart';

class EditServiceRequestScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const EditServiceRequestScreen({Key? key, required this.request})
    : super(key: key);

  @override
  _EditServiceRequestScreenState createState() =>
      _EditServiceRequestScreenState();
}

class _EditServiceRequestScreenState extends State<EditServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late EditFormData _formData;

  bool _isInitialized = false;
  bool _categoriesLoaded = false;
  bool _isDisposed = false;

  // Referencias guardadas ANTES de que el widget se desmonte
  ServiceRequestViewModel? _requestViewModel;
  CategoryViewModel? _categoryViewModel;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _formData = EditFormData.fromRequest(widget.request);
    _isInitialized = true;

    // Cargar categorías después del primer build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _loadCategoriesIfNeeded();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // CRÍTICO: Guardar referencias de forma segura aquí
    if (!_isDisposed && mounted) {
      try {
        _requestViewModel = Provider.of<ServiceRequestViewModel>(
          context,
          listen: false,
        );
        _categoryViewModel = Provider.of<CategoryViewModel>(
          context,
          listen: false,
        );
        _scaffoldMessenger = ScaffoldMessenger.of(context);
      } catch (e) {
        print('Error obteniendo ViewModels: $e');
      }
    }
  }

  void _loadCategoriesIfNeeded() {
    if (_isDisposed || !mounted) return;

    final categoryViewModel = _categoryViewModel;
    if (categoryViewModel == null) return;

    if (categoryViewModel.categories.isEmpty && !categoryViewModel.isLoading) {
      categoryViewModel
          .loadCategories()
          .then((_) {
            if (!_isDisposed && mounted) {
              setState(() {
                _categoriesLoaded = true;
              });
            }
          })
          .catchError((e) {
            print('Error cargando categorías: $e');
            if (!_isDisposed && mounted) {
              setState(() {
                _categoriesLoaded = true;
              });
            }
          });
    } else {
      if (!_isDisposed && mounted) {
        setState(() {
          _categoriesLoaded = true;
        });
      }
    }
  }

  // Método seguro para mostrar SnackBar usando la referencia guardada
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
        print('Error mostrando SnackBar: $e');
      }
    }
  }

  Future<void> _submitForm() async {
    // Verificación inicial - muy importante
    if (_isDisposed || !mounted) {
      print('Widget disposed o desmontado, cancelando submit');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final validationError = _formData.validate();
    if (validationError != null) {
      _showSafeSnackBar(validationError);
      return;
    }

    if (_formData.isSubmitting) return;

    print('Iniciando submit del formulario de edición');

    // Marcar como enviando de forma segura
    if (!_isDisposed && mounted) {
      setState(() {
        _formData.setSubmitting(true);
      });
    }

    try {
      final updatedRequest = _formData.toServiceRequest(widget.request);
      final requestViewModel = _requestViewModel;

      if (requestViewModel == null) {
        throw Exception('ViewModel no disponible');
      }

      print('Enviando actualización al repositorio...');
      final result = await requestViewModel.updateServiceRequest(
        widget.request.id,
        updatedRequest,
        _formData.photoFiles.isEmpty ? null : _formData.photoFiles,
      );

      print('Resultado de actualización: ${result.isSuccess}');

      // CRÍTICO: Verificar que el widget siga activo después de la operación asíncrona
      if (_isDisposed || !mounted) {
        print('Widget se desmontó durante la operación asíncrona');
        return;
      }

      if (result.isSuccess) {
        print('Actualización exitosa, mostrando mensaje y navegando');

        // Mostrar mensaje de éxito usando referencia segura
        _showSafeSnackBar(
          'Solicitud actualizada correctamente',
          backgroundColor: Colors.green,
        );

        // Delay para que se muestre el mensaje antes de navegar
        await Future.delayed(const Duration(milliseconds: 200));

        // Verificar nuevamente antes de navegar
        if (!_isDisposed && mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      } else {
        print('Error en actualización: ${result.error}');
        _showSafeSnackBar(
          'Error: ${result.error}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('Excepción en _submitForm: $e');
      _showSafeSnackBar('Error al actualizar: $e', backgroundColor: Colors.red);
    } finally {
      // Marcar como no enviando de forma muy segura
      if (!_isDisposed && mounted) {
        try {
          setState(() {
            _formData.setSubmitting(false);
          });
        } catch (e) {
          print('Error al actualizar estado de submit: $e');
        }
      }
    }
  }

  void _safeUpdateState(VoidCallback update) {
    if (!_isDisposed && mounted) {
      try {
        update();
        setState(() {});
      } catch (e) {
        print('Error en _safeUpdateState: $e');
      }
    }
  }

  @override
  void dispose() {
    print('EditServiceRequestScreen dispose() llamado');
    _isDisposed = true;

    // Limpiar recursos
    _formData.dispose();

    // Limpiar referencias
    _requestViewModel = null;
    _categoryViewModel = null;
    _scaffoldMessenger = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si está disposed, no construir nada
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    if (!_isInitialized || !_categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Solicitud'), elevation: 0),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Solicitud'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed:
                (_formData.isSubmitting || _isDisposed) ? null : _submitForm,
            child: Text(
              'GUARDAR',
              style: TextStyle(
                color:
                    (_formData.isSubmitting || _isDisposed)
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditInfoBanner(),
              const SizedBox(height: 24),

              EditBasicFields(formData: _formData, onUpdate: _safeUpdateState),
              const SizedBox(height: 16),

              EditCategoriesSection(
                formData: _formData,
                onUpdate: _safeUpdateState,
              ),
              const SizedBox(height: 16),

              EditUrgencySection(
                formData: _formData,
                onUpdate: _safeUpdateState,
              ),
              const SizedBox(height: 16),

              EditLocationSection(
                formData: _formData,
                onUpdate: _safeUpdateState,
              ),
              const SizedBox(height: 16),

              EditPhotosSection(
                formData: _formData,
                onUpdate: _safeUpdateState,
              ),
              const SizedBox(height: 32),

              EditSubmitButton(
                formData: _formData,
                onSubmit: (_isDisposed) ? () {} : _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
