import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';

/// HTTP client singleton berbasis Dio untuk seluruh request API Spendly.
///
/// [baseUrl] selalu dibaca dari [ApiConstants.baseUrl] saat request dikirim
/// (melalui interceptor), sehingga perubahan server IP di runtime langsung
/// berlaku tanpa perlu membuat ulang instance.
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        // baseUrl sengaja tidak di-set di sini karena interceptor onRequest
        // akan selalu membaca ApiConstants.baseUrl yang terbaru (dinamis).
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Selalu baca baseUrl terbaru — mendukung perubahan server IP runtime
          options.baseUrl = ApiConstants.baseUrl;

          // Lampirkan Sanctum token jika tersedia
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Teruskan error ke caller untuk ditangani di layer ApiService
          return handler.next(error);
        },
      ),
    );
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  /// Reset singleton (berguna saat testing atau perlu fresh instance).
  static void reset() {
    _instance = null;
  }
}
