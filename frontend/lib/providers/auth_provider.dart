import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/network/token_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService.instance;

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  UserModel? get user => _user;

  /// User dianggap terautentikasi HANYA jika ada objek user yang valid
  /// hasil dari backend (bukan fallback palsu).
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  // ─────────────────────────────────────────────────────────────────────────
  // SESSION CHECK (Startup)
  // ─────────────────────────────────────────────────────────────────────────

  /// Cek token & muat sesi pengguna saat pertama kali app dibuka.
  ///
  /// Flow:
  /// 1. Ada token tersimpan → validasi ke backend (`GET /user`)
  ///    - Berhasil → set user, navigate ke Dashboard
  ///    - Gagal (401/error) → hapus token → lanjut ke step 2
  /// 2. Tidak ada token → cek apakah Firebase user tersedia (Google Sign-In)
  ///    - Firebase user ada → sync backend → simpan token
  ///    - Tidak ada → arahkan ke LoginScreen
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        // Validasi token ke backend
        try {
          _user = await _apiService.getUserProfile();
          // Token valid — user terautentikasi
        } catch (e) {
          // Token tidak valid (401/expired/server error) — hapus token
          await TokenStorage.deleteToken();
          _user = null;

          // Cek apakah ada sesi Firebase (Google Sign-In) sebagai fallback
          await _tryFirebaseFallback();
        }
      } else {
        // Tidak ada token Sanctum — cek Firebase (Google Sign-In)
        await _tryFirebaseFallback();
      }
    } catch (_) {
      // Error tidak terduga — bersihkan semua state
      await TokenStorage.deleteToken();
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Cek apakah ada Firebase user yang aktif dan sync ke backend.
  /// Hanya dipanggil saat tidak ada Sanctum token yang valid.
  /// Jika backend tidak bisa dicapai, TIDAK membuat user palsu —
  /// biarkan _user tetap null sehingga user diarahkan ke LoginScreen.
  Future<void> _tryFirebaseFallback() async {
    final fbUser = _firebaseAuthService.currentUser;
    if (fbUser == null || fbUser.email == null) return;

    try {
      final syncResult = await _apiService.firebaseSync(
        email: fbUser.email!,
        name: fbUser.displayName ?? fbUser.email!.split('@')[0],
        avatar: fbUser.photoURL,
        firebaseUid: fbUser.uid,
      );
      _user = syncResult['user'] as UserModel;
    } catch (_) {
      // Backend tidak bisa dicapai atau sync gagal.
      // TIDAK set _user dengan data palsu — user harus login ulang.
      _user = null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOOGLE SIGN-IN
  // ─────────────────────────────────────────────────────────────────────────

  /// Login dengan Google melalui Firebase → sync ke backend Laravel.
  ///
  /// Login dianggap berhasil HANYA jika:
  /// 1. Firebase Google Sign-In berhasil, DAN
  /// 2. Backend sync berhasil dan mengembalikan token Sanctum yang valid.
  ///
  /// Jika backend tidak bisa dicapai, login GAGAL dengan pesan error jelas.
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _firebaseAuthService.signInWithGoogle();
      if (credential == null || credential.user == null) {
        // User membatalkan Google Sign-In
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final fbUser = credential.user!;
      final email = fbUser.email ?? '';
      final name = (fbUser.displayName != null && fbUser.displayName!.isNotEmpty)
          ? fbUser.displayName!
          : (email.isNotEmpty ? email.split('@')[0] : 'Teman Spendly');
      final photoUrl = fbUser.photoURL;

      // Sync ke backend — WAJIB berhasil agar login dianggap sukses.
      // Jika backend tidak bisa dicapai, kembalikan error, jangan buat user palsu.
      try {
        final syncResult = await _apiService.firebaseSync(
          email: email,
          name: name,
          avatar: photoUrl,
          firebaseUid: fbUser.uid,
        );
        _user = syncResult['user'] as UserModel;
      } catch (syncError) {
        // Backend sync gagal — batalkan login Google, sign out dari Firebase
        _errorMessage = syncError.toString().contains('Tidak dapat terhubung')
            ? 'Server backend tidak dapat dicapai. Pastikan backend aktif dan periksa pengaturan server.'
            : 'Gagal menghubungkan akun Google ke server. Coba lagi: $syncError';
        await _firebaseAuthService.signOut();
        _user = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EMAIL & PASSWORD LOGIN
  // ─────────────────────────────────────────────────────────────────────────

  /// Login dengan email & password langsung ke backend Laravel (Sanctum).
  ///
  /// Firebase TIDAK digunakan untuk email/password login.
  /// Backend adalah satu-satunya sumber kebenaran.
  ///
  /// Login dianggap berhasil HANYA jika backend mengembalikan token Sanctum.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email: email, password: password);
      _user = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────────────────────────────────

  /// Registrasi dengan name, email & password langsung ke backend Laravel.
  ///
  /// Firebase TIDAK digunakan untuk registrasi email/password.
  /// Setelah registrasi berhasil, token Sanctum langsung disimpan.
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );
      _user = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────────────────────────────────

  /// Kirim email reset password melalui Firebase.
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseAuthService.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ─────────────────────────────────────────────────────────────────────────

  /// Update profil pengguna.
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? password,
    String? avatar,
    bool clearAvatar = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update Firebase display name jika berubah
      if (name != null && name.isNotEmpty && _firebaseAuthService.currentUser != null) {
        await _firebaseAuthService.currentUser!.updateDisplayName(name);
      }

      final updated = await _apiService.updateProfile(
        name: name,
        email: email,
        password: password,
        avatar: avatar,
        clearAvatar: clearAvatar,
      );
      _user = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set avatar preset animasi.
  Future<bool> setAvatarPreset(String avatarKey) async {
    return await updateProfile(avatar: avatarKey);
  }

  /// Hapus/reset avatar ke default inisial.
  Future<bool> removeAvatar() async {
    return await updateProfile(clearAvatar: true);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPLOAD AVATAR
  // ─────────────────────────────────────────────────────────────────────────

  /// Upload foto profil kustom.
  Future<bool> uploadAvatar(Uint8List fileBytes, String fileName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.uploadAvatar(
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _user = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────────────────

  /// Logout pengguna: revoke token backend, sign out Firebase, bersihkan state.
  ///
  /// Pastikan:
  /// - Token Sanctum dihapus dari storage (dilakukan oleh ApiService.logout)
  /// - Firebase session di-sign out
  /// - State lokal (_user, _errorMessage) di-reset
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // Sign out Firebase (Google session)
    try {
      await _firebaseAuthService.signOut();
    } catch (_) {}

    // Revoke Sanctum token di backend & hapus token dari storage
    try {
      await _apiService.logout();
    } catch (_) {
      // Jika backend tidak bisa dicapai, token lokal tetap dihapus
      // oleh TokenStorage.deleteToken() di dalam ApiService.logout()
    }

    // Bersihkan semua state lokal
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UTILS
  // ─────────────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
