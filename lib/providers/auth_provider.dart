import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../services/api_service.dart';
import '../core/app_dialogs.dart';

/// Kirish, ro'yxatdan o'tish va foydalanuvchi holati.
class AuthProvider extends ChangeNotifier {
  final _api = ApiService.instance;
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _me;

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get me => _me;

  Future<bool> checkLoggedIn() async => _api.hasToken();

  Future<bool> login(String phone, String password) async {
    _startLoading();
    try {
      final res = await _api.dio.post('/auth/login/', data: {
        'phone': phone,
        'password': password,
      });
      await _api.saveTokens(res.data['access'], res.data['refresh']);
      await fetchMe();
      _stopLoading();
      return true;
    } catch (e) {
      // Login xatosi: server aniq sabab bersa o'shani, bo'lmasa tarmoq/umumiy
      if (e is DioException && e.response?.statusCode == 401) {
        _error = 'Telefon raqam yoki parol noto\'g\'ri.';
      } else {
        _error = _serverMessage(e) ?? friendlyError(e);
      }
      _stopLoading();
      return false;
    }
  }

  Future<bool> register({
    required Map<String, dynamic> data,
    XFile? image,
  }) async {
    _startLoading();
    try {
      // Rasm bo'lsa multipart (FormData), bo'lmasa oddiy JSON.
      final dynamic payload;
      if (image != null) {
        final bytes = await image.readAsBytes();
        payload = FormData.fromMap({
          ...data,
          'image': MultipartFile.fromBytes(bytes, filename: image.name),
        });
      } else {
        payload = data;
      }
      final res = await _api.dio.post('/auth/register/', data: payload);
      await _api.saveTokens(res.data['access'], res.data['refresh']);
      await fetchMe();
      _stopLoading();
      return true;
    } catch (e) {
      // Aniq sabab: serverdan kelgan xabar (telefon takror, format xato...)
      // bo'lmasa — tarmoq/rasm/umumiy xato turini aniqlaymiz.
      _error = _serverMessage(e) ?? friendlyError(e);
      _stopLoading();
      return false;
    }
  }

  /// Serverdan kelgan aniq xato matnini oladi (masalan
  /// "Bu telefon raqam ro'yxatdan o'tgan"). Yo'q bo'lsa null.
  String? _serverMessage(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.isNotEmpty) {
        // Maxsus: "detail" yoki birinchi maydon xatosi
        final val = data['detail'] ?? data.values.first;
        final text = val is List ? val.first.toString() : val.toString();
        if (text.trim().isNotEmpty) return text.trim();
      }
    }
    return null;
  }

  Future<void> fetchMe() async {
    try {
      final res = await _api.dio.get('/auth/me/');
      _me = res.data;
      notifyListeners();
    } catch (_) {}
  }

  /// Hisobni butunlay o'chirish (Google Play talabi).
  /// Backend: DELETE /auth/me/. Muvaffaqiyatli bo'lsa tokenlar tozalanadi.
  /// Server bu amalni qo'llamasa (404/405) — false + aniq xabar.
  Future<bool> deleteAccount() async {
    _startLoading();
    try {
      await _api.dio.delete('/auth/me/');
      await logout();
      _stopLoading();
      return true;
    } catch (e) {
      final code = e is DioException ? e.response?.statusCode : null;
      if (code == 404 || code == 405) {
        _error = "Hisobni o'chirish so'rovi qabul qilinmadi. "
            "Iltimos, administrator bilan bog'laning.";
      } else {
        _error = _serverMessage(e) ?? friendlyError(e);
      }
      _stopLoading();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
    _me = null;
    notifyListeners();
  }

  // Yuklash boshlanганда xatoni tozalaymiz
  void _startLoading() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  // Yuklash tugаganда xatoni SAQLAB qolamiz (null qilmaymiz!)
  void _stopLoading() {
    _loading = false;
    notifyListeners();
  }
}