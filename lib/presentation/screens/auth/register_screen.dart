import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Manejar registro con email y contraseña
  Future<void> _handleEmailRegister(AuthViewModel authViewModel) async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await authViewModel.registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone:
          _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
    );

    if (result.isSuccess && mounted) {
      // El registro fue exitoso, volver a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Inicia sesión para continuar.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  // Manejar registro con Google
  Future<void> _handleGoogleRegister(AuthViewModel authViewModel) async {
    final result = await authViewModel.signInWithGoogle();

    // Mostrar error si ocurre
    if (result.isError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Si es exitoso, el StreamBuilder manejará la navegación
  }

  // Manejar registro con Apple
  Future<void> _handleAppleRegister(AuthViewModel authViewModel) async {
    final result = await authViewModel.signInWithApple();

    // Mostrar error si ocurre
    if (result.isError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Si es exitoso, el StreamBuilder manejará la navegación
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
              title: const Text('Crear Cuenta'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    const Text(
                      'Únete a TekniGo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Crea tu cuenta para encontrar técnicos',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Formulario de registro
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            label: 'Nombre completo',
                            prefixIcon: Icons.person,
                            validator: Validators.validateName,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Correo electrónico',
                            hint: 'ejemplo@correo.com',
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Teléfono (opcional)',
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: Validators.validatePhone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            prefixIcon: Icons.lock,
                            isPassword: true,
                            validator: Validators.validatePassword,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar contraseña',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator:
                                (value) => Validators.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                            textInputAction: TextInputAction.done,
                            onSubmitted:
                                (_) => _handleEmailRegister(authViewModel),
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

                          const SizedBox(height: 24),

                          // Botón de registro
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  authViewModel.isRegistering ||
                                          authViewModel.isLoading
                                      ? null
                                      : () =>
                                          _handleEmailRegister(authViewModel),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  authViewModel.isRegistering ||
                                          authViewModel.isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        'REGISTRARSE',
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

                    const SizedBox(height: 16),

                    // Divisor con texto "O"
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'O regístrate con',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Botones de registro con redes sociales
                    SocialLoginButton(
                      type: SocialLoginType.google,
                      isLoading: authViewModel.isGoogleSigningIn,
                      onPressed: () => _handleGoogleRegister(authViewModel),
                    ),

                    // Mostrar botón de Apple solo en iOS
                    if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        type: SocialLoginType.apple,
                        isLoading: authViewModel.isAppleSigningIn,
                        onPressed: () => _handleAppleRegister(authViewModel),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Texto de términos y condiciones
                    const Text(
                      'Al registrarte, aceptas nuestros Términos de servicio y Política de privacidad',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
