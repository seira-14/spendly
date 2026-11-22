import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../core/network/token_storage.dart';
import '../models/category_model.dart';
import '../models/dashboard_model.dart';
import '../models/expense_model.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';

class ApiService {
  final Dio _dio = DioClient.instance.dio;

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────────────────

  /// Registrasi pengguna baru.
  ///
  /// Throws: String pesan error jika validasi atau request gagal.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final body = response.data;
      _assertSuccess(body, context: 'register');

      final data = body['data'];
      if (data == null || data['user'] == null || data['token'] == null) {
        throw 'Respons server tidak valid saat registrasi.';
      }

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      await TokenStorage.saveToken(token);
      await TokenStorage.saveLastEmail(email);

      return {'user': user, 'token': token};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Login pengguna dengan email & password.
  ///
  /// Backend adalah satu-satunya sumber kebenaran.
  /// Token HANYA disimpan jika backend mengembalikan response sukses.
  ///
  /// Throws: String pesan error jika credential salah atau request gagal.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final body = response.data;
      _assertSuccess(body, context: 'login');

      final data = body['data'];
      if (data == null || data['user'] == null || data['token'] == null) {
        throw 'Respons server tidak valid saat login.';
      }

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      // Token disimpan HANYA setelah semua validasi berhasil
      await TokenStorage.saveToken(token);
      await TokenStorage.saveLastEmail(email);

      return {'user': user, 'token': token};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Sinkronisasi pengguna Firebase / Google ke backend Laravel.
  ///
  /// Dipanggil setelah Google Sign-In berhasil.
  /// Throws: String pesan error jika sync gagal.
  Future<Map<String, dynamic>> firebaseSync({
    required String email,
    required String name,
    String? avatar,
    String? firebaseUid,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.firebaseSync,
        data: {
          'email': email,
          'name': name,
          'avatar': avatar,
          'firebase_uid': firebaseUid,
        },
      );

      final body = response.data;
      _assertSuccess(body, context: 'firebase-sync');

      final data = body['data'];
      if (data == null || data['user'] == null || data['token'] == null) {
        throw 'Respons server tidak valid saat sinkronisasi Firebase.';
      }

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      await TokenStorage.saveToken(token);
      await TokenStorage.saveLastEmail(email);

      return {'user': user, 'token': token};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout pengguna: revoke token di backend dan hapus dari storage lokal.
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Abaikan network failure saat logout — token lokal tetap dihapus
    } finally {
      await TokenStorage.deleteToken();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USER PROFILE
  // ─────────────────────────────────────────────────────────────────────────

  /// Ambil profil pengguna yang sedang login.
  ///
  /// Digunakan oleh [AuthProvider.checkAuthStatus] untuk memvalidasi token.
  /// Throws: DioException (termasuk 401) jika token tidak valid.
  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.user);
      final data = response.data['data']?['user'] ??
          response.data['data'] ??
          response.data;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update profil pengguna.
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? password,
    String? avatar,
    bool clearAvatar = false,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (name != null && name.isNotEmpty) map['name'] = name;
      if (email != null && email.isNotEmpty) map['email'] = email;
      if (password != null && password.isNotEmpty) map['password'] = password;
      if (clearAvatar) {
        map['avatar'] = null;
      } else if (avatar != null) {
        map['avatar'] = avatar;
      }

      final response = await _dio.put(ApiConstants.user, data: map);
      final data = response.data['data']['user'];
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload foto profil kustom.
  Future<UserModel> uploadAvatar({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiConstants.avatar,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data['data']['user'];
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────────────────

  /// Ambil semua kategori pengeluaran.
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);
      final list = (response.data['data']?['categories'] as List<dynamic>?) ?? [];
      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DASHBOARD
  // ─────────────────────────────────────────────────────────────────────────

  /// Ambil data dashboard (ringkasan pengeluaran bulan ini).
  Future<DashboardModel> getDashboard({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        ApiConstants.dashboard,
        queryParameters: queryParams,
      );

      return DashboardModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXPENSES
  // ─────────────────────────────────────────────────────────────────────────

  /// Ambil daftar pengeluaran dengan filter opsional.
  Future<List<ExpenseModel>> getExpenses({
    int? month,
    int? year,
    int? categoryId,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        ApiConstants.expenses,
        queryParameters: queryParams,
      );

      final list = (response.data['data']?['expenses'] as List<dynamic>?) ?? [];
      return list.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Buat pengeluaran baru.
  Future<ExpenseModel> createExpense({
    required int categoryId,
    required String title,
    required double amount,
    required String date,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.expenses,
        data: {
          'category_id': categoryId,
          'title': title,
          'amount': amount,
          'date': date,
          'notes': notes,
        },
      );

      final data = response.data['data']['expense'];
      return ExpenseModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update pengeluaran.
  Future<ExpenseModel> updateExpense({
    required int id,
    int? categoryId,
    String? title,
    double? amount,
    String? date,
    String? notes,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (categoryId != null) map['category_id'] = categoryId;
      if (title != null) map['title'] = title;
      if (amount != null) map['amount'] = amount;
      if (date != null) map['date'] = date;
      if (notes != null) map['notes'] = notes;

      final response = await _dio.put(
        '${ApiConstants.expenses}/$id',
        data: map,
      );

      final data = response.data['data']['expense'];
      return ExpenseModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Hapus pengeluaran.
  Future<void> deleteExpense(int id) async {
    try {
      await _dio.delete('${ApiConstants.expenses}/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REPORTS
  // ─────────────────────────────────────────────────────────────────────────

  /// Ambil laporan analitik pengeluaran.
  Future<ReportModel> getReports({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        ApiConstants.reports,
        queryParameters: queryParams,
      );

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Validasi bahwa response body memiliki status 'success'.
  /// Throw pesan error dari body jika tidak.
  void _assertSuccess(dynamic body, {required String context}) {
    if (body is! Map<String, dynamic>) {
      throw 'Respons server tidak dikenali ($context).';
    }
    if (body['status'] != 'success') {
      final msg = body['message'];
      throw (msg is String && msg.isNotEmpty)
          ? msg
          : 'Permintaan $context gagal.';
    }
  }

  /// Format pesan error dari DioException menjadi String yang ramah pengguna.
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // Pesan error dari backend (misal: "Email atau password salah.")
        if (data['message'] != null) {
          return data['message'].toString();
        }
        // Validation errors dari Laravel (422)
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstKey = errors.keys.first;
            final firstVal = errors[firstKey];
            if (firstVal is List && firstVal.isNotEmpty) {
              return firstVal.first.toString();
            }
          }
        }
      }
      return 'Terjadi kesalahan dari server (${e.response?.statusCode}).';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi waktu habis. Periksa koneksi backend Anda.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan backend aktif di ${ApiConstants.baseUrl}.';
    }
    return 'Terjadi kesalahan tidak terduga: ${e.message}';
  }
}
