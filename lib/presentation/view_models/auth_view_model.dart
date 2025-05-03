import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();

  // Estados para procesos específicos
  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

  bool _isResettingPassword = false;
  bool get isResettingPassword => _isResettingPassword;

  bool _isGoogleSigningIn = false;
  bool get isGoogleSigningIn => _isGoogleSigningIn;

  bool _isAppleSigningIn = false;
  bool get isAppleSigningIn => _isAppleSigningIn;

  // Usuario actual
  User? get currentUser => _authRepository.currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  // Iniciar sesión con email y contraseña
  Future<Resource<UserCredential>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      setLoading();

      final userCredential = await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );

      setLoaded();
      return Resource.success(userCredential);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No existe cuenta con este correo';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        case 'user-disabled':
          errorMessage = 'Esta cuenta ha sido deshabilitada';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos fallidos. Intenta más tarde';
          break;
        default:
          errorMessage = e.message ?? 'Error desconocido en inicio de sesión';
      }

      setError(errorMessage);
      return Resource.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Error inesperado: ${e.toString()}';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Registro con email y contraseña
  Future<Resource<UserCredential>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _isRegistering = true;
      setLoading();

      final userCredential = await _authRepository.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      _isRegistering = false;
      setLoaded();
      return Resource.success(userCredential);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este correo ya está registrado';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es demasiado débil';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido';
          break;
        default:
          errorMessage = e.message ?? 'Error desconocido en registro';
      }

      _isRegistering = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Error inesperado: ${e.toString()}';
      _isRegistering = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Inicio de sesión con Google
  Future<Resource<UserCredential?>> signInWithGoogle() async {
    try {
      _isGoogleSigningIn = true;
      setLoading();

      final userCredential = await _authRepository.signInWithGoogle();

      _isGoogleSigningIn = false;
      setLoaded();
      return Resource.success(userCredential);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'sign_in_canceled':
          errorMessage = 'Inicio de sesión cancelado';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'Ya existe una cuenta con este correo';
          break;
        case 'google_sign_in_failed':
          errorMessage = 'Error al iniciar sesión con Google';
          break;
        default:
          errorMessage = e.message ?? 'Error en inicio de sesión con Google';
      }

      _isGoogleSigningIn = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Error inesperado: ${e.toString()}';
      _isGoogleSigningIn = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Inicio de sesión con Apple
  Future<Resource<UserCredential?>> signInWithApple() async {
    try {
      _isAppleSigningIn = true;
      setLoading();

      final userCredential = await _authRepository.signInWithApple();

      _isAppleSigningIn = false;
      setLoaded();
      return Resource.success(userCredential);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'apple-sign-in-not-available':
          errorMessage =
              'Inicio de sesión con Apple no disponible en este dispositivo';
          break;
        case 'apple-sign-in-failed':
          errorMessage = 'Error al iniciar sesión con Apple';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'Ya existe una cuenta con este correo';
          break;
        case 'apple-sign-in-unknown-error':
          errorMessage = 'Error desconocido al iniciar sesión con Apple';
          break;
        default:
          errorMessage = e.message ?? 'Error en inicio de sesión con Apple';
      }

      _isAppleSigningIn = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Error inesperado: ${e.toString()}';
      _isAppleSigningIn = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Restablecer contraseña
  Future<Resource<void>> resetPassword(String email) async {
    try {
      _isResettingPassword = true;
      setLoading();

      await _authRepository.resetPassword(email);

      _isResettingPassword = false;
      setLoaded();
      return Resource.success(null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No existe cuenta con este correo';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido';
          break;
        default:
          errorMessage =
              e.message ?? 'Error al enviar email de restablecimiento';
      }

      _isResettingPassword = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Error inesperado: ${e.toString()}';
      _isResettingPassword = false;
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Cerrar sesión
  Future<Resource<void>> signOut() async {
    try {
      setLoading();

      await _authRepository.signOut();

      setLoaded();
      return Resource.success(null);
    } catch (e) {
      final errorMessage = 'Error al cerrar sesión: ${e.toString()}';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Obtener datos del usuario
  Future<Resource<Map<String, dynamic>?>> getUserData() async {
    try {
      setLoading();

      final userData = await _authRepository.getUserData();

      setLoaded();
      return Resource.success(userData);
    } catch (e) {
      final errorMessage =
          'Error al obtener datos del usuario: ${e.toString()}';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Actualizar perfil del usuario
  Future<Resource<void>> updateUserProfile(
    Map<String, dynamic> userData,
  ) async {
    try {
      setLoading();

      await _authRepository.updateUserProfile(userData);

      setLoaded();
      return Resource.success(null);
    } catch (e) {
      final errorMessage = 'Error al actualizar perfil: ${e.toString()}';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Cambiar contraseña
  Future<Resource<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      setLoading();

      await _authRepository.changePassword(currentPassword, newPassword);

      setLoaded();
      return Resource.success(null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'La nueva contraseña es demasiado débil';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Por seguridad, debes volver a iniciar sesión antes de cambiar tu contraseña';
          break;
        case 'wrong-password':
          errorMessage = 'La contraseña actual es incorrecta';
          break;
        default:
          errorMessage = e.message ?? 'Error al cambiar contraseña';
      }

      setError(errorMessage);
      return Resource.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Error inesperado: ${e.toString()}';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }
}
