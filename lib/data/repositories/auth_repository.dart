import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/constants/app_constants.dart';

/// Repositorio para manejar todas las operaciones relacionadas con autenticación
///
/// Este repositorio encapsula toda la lógica de acceso a Firebase Auth
/// y la interacción con Firestore para los datos de usuario.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registro con correo y contraseña
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Crear el usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si la creación fue exitosa, guardar datos adicionales en Firestore
      if (userCredential.user != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set({
              'name': name,
              'email': email,
              'phone': phone,
              'userType': AppConstants.userTypeRegular,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': FieldValue.serverTimestamp(),
              'authProvider': 'email',
            });

        // Actualizar el displayName del usuario en Firebase Auth
        await userCredential.user!.updateDisplayName(name);
      }

      return userCredential;
    } catch (e) {
      print('Error en registro: $e');
      rethrow; // Re-lanzar la excepción para manejarla en la capa superior
    }
  }

  // Inicio de sesión con correo y contraseña
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar la fecha de último inicio de sesión
      if (userCredential.user != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .update({'lastLogin': FieldValue.serverTimestamp()});
      }

      return userCredential;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // Inicio de sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Verificar si ya está iniciada sesión y cerrarla primero
      await _googleSignIn.signOut();

      // Iniciar el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        throw FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'El inicio de sesión con Google fue cancelado.',
        );
      }

      // Obtener detalles de autenticación de la solicitud
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con la credencial
      final userCredential = await _auth.signInWithCredential(credential);

      // Si es un nuevo usuario, guardar datos en Firestore
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set({
              'name': userCredential.user!.displayName ?? 'Usuario',
              'email': userCredential.user!.email ?? '',
              'userType': AppConstants.userTypeRegular,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': FieldValue.serverTimestamp(),
              'authProvider': 'google',
              'photoURL': userCredential.user!.photoURL,
            });
      } else {
        // Verificar si existe el documento en Firestore
        final userDoc =
            await _firestore
                .collection(AppConstants.usersCollection)
                .doc(userCredential.user!.uid)
                .get();

        if (userDoc.exists) {
          // Actualizar fecha de último inicio de sesión
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .update({'lastLogin': FieldValue.serverTimestamp()});
        } else {
          // Crear documento si no existe
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .set({
                'name': userCredential.user!.displayName ?? 'Usuario',
                'email': userCredential.user!.email ?? '',
                'userType': AppConstants.userTypeRegular,
                'createdAt': FieldValue.serverTimestamp(),
                'lastLogin': FieldValue.serverTimestamp(),
                'authProvider': 'google',
                'photoURL': userCredential.user!.photoURL,
              });
        }
      }

      return userCredential;
    } catch (e) {
      print('Error detallado en inicio de sesión con Google: $e');
      if (e is FirebaseAuthException) {
        // Relanzar la excepción original
        rethrow;
      } else {
        // Convertir otras excepciones a FirebaseAuthException para manejo unificado
        throw FirebaseAuthException(
          code: 'google_sign_in_failed',
          message: 'Error al iniciar sesión con Google: ${e.toString()}',
        );
      }
    }
  }

  // Inicio de sesión con Apple (solo disponible en iOS)
  Future<UserCredential?> signInWithApple() async {
    try {
      // Verificar si el inicio de sesión con Apple está disponible en este dispositivo
      final isAvailable = await SignInWithApple.isAvailable();

      if (!isAvailable) {
        throw FirebaseAuthException(
          code: 'apple-sign-in-not-available',
          message:
              'El inicio de sesión con Apple no está disponible en este dispositivo',
        );
      }

      // Comenzar el proceso de inicio de sesión con Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Crear credencial para Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Iniciar sesión en Firebase con esa credencial
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Si es un nuevo usuario, guardar datos en Firestore
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Apple puede ocultar el email después del primer inicio de sesión
        // y fullName puede estar vacío, así que maneja esos casos
        String? name = appleCredential.givenName;
        if ((name == null || name.isEmpty) &&
            appleCredential.familyName != null &&
            appleCredential.familyName!.isNotEmpty) {
          name = appleCredential.familyName;
        }

        // Si aún no tenemos nombre, usamos el displayName de Firebase o "Usuario de Apple"
        if (name == null || name.isEmpty) {
          name = userCredential.user?.displayName ?? 'Usuario de Apple';
        }

        // Extraer email (puede estar vacío en inicios de sesión posteriores)
        final email =
            appleCredential.email ??
            userCredential.user?.email ??
            'no-email@apple.user';

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set({
              'name': name,
              'email': email,
              'userType': AppConstants.userTypeRegular,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': FieldValue.serverTimestamp(),
              'authProvider': 'apple',
            });
      } else {
        // Actualizar fecha de último inicio de sesión
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .update({'lastLogin': FieldValue.serverTimestamp()});
      }

      return userCredential;
    } catch (e) {
      print('Error detallado en inicio de sesión con Apple: $e');
      if (e is SignInWithAppleException) {
        throw FirebaseAuthException(
          code: 'apple-sign-in-failed',
          message: 'Error al iniciar sesión con Apple: ${e.toString()}',
        );
      } else if (e is FirebaseAuthException) {
        rethrow;
      } else {
        throw FirebaseAuthException(
          code: 'apple-sign-in-unknown-error',
          message:
              'Error desconocido al iniciar sesión con Apple: ${e.toString()}',
        );
      }
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al enviar email de restablecimiento: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      // Cerrar sesión en Firebase primero
      await _auth.signOut();

      // Luego intentar cerrar sesión en Google
      try {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      } catch (e) {
        print('Error al cerrar sesión en Google (no crítico): $e');
        // No relanzamos esta excepción ya que la sesión de Firebase ya está cerrada
      }
    } catch (e) {
      print('Error crítico al cerrar sesión: $e');
      rethrow;
    }
  }

  // Obtener datos completos del usuario
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      final doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(currentUser!.uid)
              .get();

      if (doc.exists) {
        return doc.data();
      } else {
        // Si no existe el documento pero el usuario está autenticado,
        // crear un documento básico con la información disponible
        final userData = {
          'name': currentUser!.displayName ?? 'Usuario',
          'email': currentUser!.email ?? '',
          'userType': AppConstants.userTypeRegular,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'authProvider': _determineAuthProvider(currentUser!),
          'photoURL': currentUser!.photoURL,
        };

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUser!.uid)
            .set(userData);
        return userData;
      }
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      throw e;
    }
  }

  // Determinar el proveedor de autenticación basado en la información del usuario
  String _determineAuthProvider(User user) {
    if (user.providerData.isEmpty) return 'unknown';

    final providerId = user.providerData[0].providerId;

    if (providerId.contains('google')) return 'google';
    if (providerId.contains('apple')) return 'apple';
    if (providerId.contains('password')) return 'email';

    return 'unknown';
  }

  // Actualizar perfil del usuario
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      if (currentUser == null) return;

      // Actualizar en Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser!.uid)
          .update({...userData, 'updatedAt': FieldValue.serverTimestamp()});

      // Si incluye nombre, actualizar también en Firebase Auth
      if (userData.containsKey('name')) {
        await currentUser!.updateDisplayName(userData['name']);
      }
    } catch (e) {
      print('Error al actualizar perfil: $e');
      rethrow;
    }
  }

  // Cambiar contraseña
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No hay usuario autenticado o email no disponible');
      }

      // Reautenticar
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);
    } catch (e) {
      print('Error al cambiar contraseña: $e');
      rethrow;
    }
  }
}
