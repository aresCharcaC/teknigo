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

  @override
  void initState() {
    super.initState();
    // SOLUCION: Inicializar datos sin usar setState
    _formData = EditFormData.fromRequest(widget.request);

    // Cargar categorías en el siguiente frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesIfNeeded();
      // Marcar como inicializado DESPUES del primer build
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  void _loadCategoriesIfNeeded() {
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
      listen: false,
    );
    if (categoryViewModel.categories.isEmpty) {
      categoryViewModel.loadCategories();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validaciones usando formData
    final validationError = _formData.validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _formData.setSubmitting(true);
    setState(() {}); // Solo actualizamos UI

    try {
      // Crear objeto actualizado usando formData
      final updatedRequest = _formData.toServiceRequest(widget.request);

      // Usar el ViewModel para actualizar
      final requestViewModel = Provider.of<ServiceRequestViewModel>(
        context,
        listen: false,
      );

      final result = await requestViewModel.updateServiceRequest(
        widget.request.id,
        updatedRequest,
        _formData.photoFiles.isEmpty ? null : _formData.photoFiles,
      );

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitud actualizada correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la solicitud: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        _formData.setSubmitting(false);
        setState(() {});
      }
    }
  }

  void _updateFormData(VoidCallback update) {
    update();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar carga inicial si no está inicializado
    if (!_isInitialized) {
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
              // Banner informativo
              const EditInfoBanner(),

              const SizedBox(height: 24),

              // Campos básicos (título y descripción)
              EditBasicFields(formData: _formData, onUpdate: _updateFormData),

              const SizedBox(height: 16),

              // Sección de categorías
              EditCategoriesSection(
                formData: _formData,
                onUpdate: _updateFormData,
              ),

              const SizedBox(height: 16),

              // Sección de urgencia
              EditUrgencySection(
                formData: _formData,
                onUpdate: _updateFormData,
              ),

              const SizedBox(height: 16),

              // Sección de ubicación
              EditLocationSection(
                formData: _formData,
                onUpdate: _updateFormData,
              ),

              const SizedBox(height: 16),

              // Sección de fotos
              EditPhotosSection(formData: _formData, onUpdate: _updateFormData),

              const SizedBox(height: 32),

              // Botón de envío
              EditSubmitButton(formData: _formData, onSubmit: _submitForm),
            ],
          ),
        ),
      ),
    );
  }
}
