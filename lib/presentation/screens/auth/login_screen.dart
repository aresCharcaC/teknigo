import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../view_models/auth_view_model.dart';
import 'components/custom_text_field.dart';
import 'components/social_login_button.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Manejar inicio de sesión con email y contraseña
  Future<void> _handleEmailLogin(AuthViewModel authViewModel) async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await authViewModel.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // No necesitamos navegar manualmente, el listener de autenticación lo hará
    // Solo mostramos errores si ocurren
    if (result.isError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Manejar inicio de sesión con Google
  Future<void> _handleGoogleLogin(AuthViewModel authViewModel) async {
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
  }

  // Manejar inicio de sesión con Apple
  Future<void> _handleAppleLogin(AuthViewModel authViewModel) async {
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
              title: const Text(AppConstants.appName),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo o imagen de la app
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Image.asset(
                        'assets/images/logo.png', // Asegúrate de tener esta imagen
                        height: 120,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.handyman,
                              size: 120,
                              color: Colors.blue,
                            ),
                      ),
                    ),

                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Conecta con técnicos cerca de ti',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Formulario de inicio de sesión
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
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            prefixIcon: Icons.lock,
                            isPassword: true,
                            validator: Validators.validatePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted:
                                (_) => _handleEmailLogin(authViewModel),
                          ),

                          // Enlace para recuperar contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ResetPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ),

                          // Mostrar mensaje de error si existe
                          if (authViewModel.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
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

                          // Botón de inicio de sesión
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  authViewModel.isLoading
                                      ? null
                                      : () => _handleEmailLogin(authViewModel),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
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
                                        'INICIAR SESIÓN',
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
                            'O',
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

                    // Botones de inicio de sesión con redes sociales
                    SocialLoginButton(
                      type: SocialLoginType.google,
                      isLoading: authViewModel.isGoogleSigningIn,
                      onPressed: () => _handleGoogleLogin(authViewModel),
                    ),

                    // Mostrar botón de Apple solo en iOS
                    if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        type: SocialLoginType.apple,
                        isLoading: authViewModel.isAppleSigningIn,
                        onPressed: () => _handleAppleLogin(authViewModel),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Enlace a registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes una cuenta?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Regístrate'),
                        ),
                      ],
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
