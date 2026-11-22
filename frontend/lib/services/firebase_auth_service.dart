import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._internal();
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '102938475610-spendly.apps.googleusercontent.com' : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase User
  User? get currentUser => _auth.currentUser;

  /// Native Google Sign-In Flow
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Use Firebase Auth Web Popup for Google Provider
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        try {
          final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
          return userCredential;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
            return null;
          }
          throw _parseFirebaseAuthError(e);
        } catch (webErr) {
          if (webErr.toString().contains('popup-closed-by-user') ||
              webErr.toString().contains('cancelled')) {
            return null;
          }
          throw 'Gagal masuk dengan Google di Web: $webErr';
        }
      } else {
        // Native Mobile (Android / iOS)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          // The user canceled the sign-in flow
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          if (googleUser.displayName != null &&
              (userCredential.user!.displayName == null || userCredential.user!.displayName!.isEmpty)) {
            await userCredential.user!.updateDisplayName(googleUser.displayName);
          }
          if (googleUser.photoUrl != null &&
              (userCredential.user!.photoURL == null || userCredential.user!.photoURL!.isEmpty)) {
            await userCredential.user!.updatePhotoURL(googleUser.photoUrl);
          }
          await userCredential.user!.reload();
        }

        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
        return null;
      }
      debugPrint('FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}');
      throw _parseFirebaseAuthError(e);
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      if (e.toString().contains('popup-closed-by-user') ||
          e.toString().contains('sign_in_canceled') ||
          e.toString().contains('cancelled')) {
        return null;
      }
      if (e.toString().contains('network_error')) {
        throw 'Gagal terhubung ke layanan Google. Periksa koneksi internet Anda.';
      }
      throw 'Gagal masuk dengan Google: ${e.toString().replaceAll('Exception:', '').trim()}';
    }
  }

  /// Sign In with Email and Password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _parseFirebaseAuthError(e);
    } catch (e) {
      throw 'Gagal masuk: $e';
    }
  }

  /// Register new user with Name, Email and Password
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
        await credential.user!.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _parseFirebaseAuthError(e);
    } catch (e) {
      throw 'Gagal mendaftar: $e';
    }
  }

  /// Send Password Reset Email (Forgot Password)
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _parseFirebaseAuthError(e);
    } catch (e) {
      throw 'Gagal mengirim email reset: $e';
    }
  }

  /// Sign Out from Google and Firebase
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}

    try {
      await _auth.signOut();
    } catch (_) {}
  }

  /// Format Firebase error codes into helpful user messages in Indonesian
  String _parseFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun dengan email ini belum terdaftar.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi yang Anda masukkan salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan masuk menggunakan email ini.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan. Hubungi bantuan Spendly.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan coba lagi beberapa saat lagi.';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan di konfigurasi Firebase.';
      case 'network-request-failed':
        return 'Gagal terhubung. Periksa koneksi internet Anda.';
      case 'account-exists-with-different-credential':
        return 'Akun dengan email ini sudah ada dengan metode login berbeda.';
      case 'popup-blocked':
        return 'Jendela popup diblokir oleh browser. Harap izinkan popup di browser Anda.';
      case 'unauthorized-domain':
        return 'Domain web ini belum diizinkan di Firebase Console OAuth domains.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi (${e.code}).';
    }
  }
}
