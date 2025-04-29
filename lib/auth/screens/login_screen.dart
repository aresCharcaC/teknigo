import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../../core/utils/validators.dart';
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
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Manejar inicio de sesión con email y contraseña
  Future<void> _handleEmailLogin() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // No necesitamos navegar manualmente, el listener de autenticación lo hará
    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = 'No existe cuenta con este correo';
              break;
            case 'wrong-password':
              _errorMessage = 'Contraseña incorrecta';
              break;
            case 'user-disabled':
              _errorMessage = 'Esta cuenta ha sido deshabilitada';
              break;
            case 'too-many-requests':
              _errorMessage = 'Demasiados intentos fallidos. Intenta más tarde';
              break;
            default:
              _errorMessage = 'Error: ${e.message}';
          }
        } else {
          _errorMessage = 'Ocurrió un error inesperado';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Manejar inicio de sesión con Google
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.signInWithGoogle();
      // No necesitamos navegar manualmente, el listener de autenticación lo hará
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión con Google';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // Manejar inicio de sesión con Apple
  Future<void> _handleAppleLogin() async {
    setState(() {
      _isAppleLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.signInWithApple();
      // No necesitamos navegar manualmente, el listener de autenticación lo hará
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión con Apple';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAppleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TekniGo'), centerTitle: true),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      onSubmitted: (_) => _handleEmailLogin(),
                    ),

                    // Enlace para recuperar contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResetPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),

                    // Mostrar mensaje de error si existe
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage,
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
                        onPressed: _isLoading ? null : _handleEmailLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
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
                isLoading: _isGoogleLoading,
                onPressed: _handleGoogleLogin,
              ),

              // Mostrar botón de Apple solo en iOS
              if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                const SizedBox(height: 12),
                SocialLoginButton(
                  type: SocialLoginType.apple,
                  isLoading: _isAppleLoading,
                  onPressed: _handleAppleLogin,
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
  }
}
