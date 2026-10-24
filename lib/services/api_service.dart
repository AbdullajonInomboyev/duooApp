import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config.dart';

/// Barcha API so'rovlari shu xizmat orqali o'tadi.
/// Token avtomatik qo'shiladi, muddati o'tsa yangilanadi.
class ApiService {
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // 401 -> tokenni yangilashga urinish (har so'rov uchun faqat 1 marta).
        // Login/ro'yxatdan o'tishdagi 401 — bu noto'g'ri parol, refresh emas.
        final opts = e.requestOptions;
        final isAuthCall = opts.path.startsWith('/auth/login') ||
            opts.path.startsWith('/auth/register');
        if (e.response?.statusCode == 401 &&
            !isAuthCall &&
            opts.extra['retried'] != true) {
          final refreshed = await _refreshOnce();
          if (refreshed) {
            try {
              final token = await _storage.read(key: 'access');
              opts.headers['Authorization'] = 'Bearer $token';
              opts.extra['retried'] = true;
              final clone = await _dio.fetch(opts);
              return handler.resolve(clone);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
          // Refresh ham o'tmadi -> sessiya tugagan, qayta kirish kerak
          if (await hasToken()) {
            await clearTokens();
            onSessionExpired?.call();
          }
        }
        handler.next(e);
      },
    ));
  }

  static final ApiService instance = ApiService._internal();
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  /// Sessiya tugaganda (refresh token ham yaroqsiz) chaqiriladi —
  /// main.dart foydalanuvchini kirish oynasiga yuboradi.
  VoidCallback? onSessionExpired;

  // Bir vaqtda bir nechta so'rov 401 olsa, refresh faqat bir marta bajariladi
  Future<bool>? _refreshing;

  Future<bool> _refreshOnce() {
    return _refreshing ??= _tryRefresh().whenComplete(() => _refreshing = null);
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    return (await _storage.read(key: 'access')) != null;
  }

  Future<bool> _tryRefresh() async {
    try {
      final refresh = await _storage.read(key: 'refresh');
      if (refresh == null) return false;
      final res = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      )).post(
        '${AppConfig.apiBaseUrl}/auth/refresh/',
        data: {'refresh': refresh},
      );
      await _storage.write(key: 'access', value: res.data['access']);
      // SimpleJWT ROTATE_REFRESH_TOKENS yoqilgan bo'lsa yangi refresh ham keladi
      if (res.data['refresh'] is String) {
        await _storage.write(key: 'refresh', value: res.data['refresh']);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
