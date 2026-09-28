import 'package:dio/dio.dart';
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
        // 401 -> tokenni yangilashga urinish
        if (e.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final opts = e.requestOptions;
            final token = await _storage.read(key: 'access');
            opts.headers['Authorization'] = 'Bearer $token';
            final clone = await _dio.fetch(opts);
            return handler.resolve(clone);
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
      final res = await Dio().post(
        '${AppConfig.apiBaseUrl}/auth/refresh/',
        data: {'refresh': refresh},
      );
      await _storage.write(key: 'access', value: res.data['access']);
      return true;
    } catch (_) {
      return false;
    }
  }
}
