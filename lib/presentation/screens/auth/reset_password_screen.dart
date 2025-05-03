import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Manejar el restablecimiento de contraseña
  Future<void> _handleResetPassword(AuthViewModel authViewModel) async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await authViewModel.resetPassword(
      _emailController.text.trim(),
    );

    if (result.isSuccess && mounted) {
      // Indicar que el correo se envió correctamente
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Builder(
        builder: (context) {
          final authViewModel = Provider.of<AuthViewModel>(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Restablecer Contraseña'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    _emailSent
                        ? _buildSuccessView()
                        : _buildResetForm(authViewModel),
              ),
            ),
          );
        },
      ),
    );
  }

  // Vista cuando el correo se ha enviado exitosamente
  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.email, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 24),
          const Text(
            '¡Correo enviado!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hemos enviado instrucciones para restablecer tu contraseña a:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _emailController.text.trim(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Por favor revisa tu bandeja de entrada y sigue las instrucciones.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Volver al Inicio de Sesión'),
          ),
        ],
      ),
    );
  }

  // Formulario para solicitar restablecimiento de contraseña
  Widget _buildResetForm(AuthViewModel authViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Restablecer Contraseña',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Te enviaremos instrucciones para restablecer tu contraseña a tu correo electrónico',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                hint: 'ejemplo@correo.com',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleResetPassword(authViewModel),
              ),

              // Mostrar mensaje de error si existe
              if (authViewModel.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    authViewModel.errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),

              // Botón para enviar solicitud
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      authViewModel.isResettingPassword ||
                              authViewModel.isLoading
                          ? null
                          : () => _handleResetPassword(authViewModel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      authViewModel.isResettingPassword ||
                              authViewModel.isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'ENVIAR INSTRUCCIONES',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
