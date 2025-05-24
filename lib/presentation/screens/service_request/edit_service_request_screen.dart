// lib/presentation/screens/service_request/edit_service_request_screen.dart
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

  // Referencias guardadas para uso seguro
  ServiceRequestViewModel? _requestViewModel;
  CategoryViewModel? _categoryViewModel;

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

    // Guardar referencias de ViewModels de forma segura
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

  Future<void> _submitForm() async {
    // Verificación inicial
    if (_isDisposed || !mounted) return;

    if (!_formKey.currentState!.validate()) return;

    final validationError = _formData.validate();
    if (validationError != null) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (_formData.isSubmitting) return;

    // Marcar como enviando
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

      final result = await requestViewModel.updateServiceRequest(
        widget.request.id,
        updatedRequest,
        _formData.photoFiles.isEmpty ? null : _formData.photoFiles,
      );

      // Verificar que el widget siga activo después de la operación asíncrona
      if (_isDisposed || !mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud actualizada correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Delay pequeño para que se muestre el mensaje
        await Future.delayed(const Duration(milliseconds: 150));

        if (!_isDisposed && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error en _submitForm: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      // Marcar como no enviando
      if (!_isDisposed && mounted) {
        setState(() {
          _formData.setSubmitting(false);
        });
      }
    }
  }

  void _safeUpdateState(VoidCallback update) {
    if (!_isDisposed && mounted) {
      update();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _formData.dispose();
    _requestViewModel = null;
    _categoryViewModel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _formData.isSubmitting ? null : _submitForm,
            child: Text(
              'GUARDAR',
              style: TextStyle(
                color:
                    _formData.isSubmitting
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

              EditSubmitButton(formData: _formData, onSubmit: _submitForm),
            ],
          ),
        ),
      ),
    );
  }
}
