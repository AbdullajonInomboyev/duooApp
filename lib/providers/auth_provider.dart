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
    _setLoading(true);
    try {
      final res = await _api.dio.post('/auth/login/', data: {
        'phone': phone,
        'password': password,
      });
      await _api.saveTokens(res.data['access'], res.data['refresh']);
      await fetchMe();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Telefon yoki parol xato';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required Map<String, dynamic> data,
    XFile? image,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      // Rasm bo'lsa multipart (FormData), bo'lmasa oddiy JSON.
      // XFile.readAsBytes() web va mobilda ishlaydi.
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
      _setLoading(false);
      return true;
    } catch (e) {
      // Serverdan aniq sabab kelsa o'shani, bo'lmasa xato turini aniqlaymiz
      String msg;
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data.isNotEmpty) {
          final val = data.values.first;
          msg = val is List ? val.first.toString() : val.toString();
        } else {
          msg = friendlyError(e);
        }
      } else if (e is DioException && e.response?.statusCode == 413) {
        msg = 'Do\'kon rasmi juda katta. Kichikroq rasm tanlang.';
      } else if (e is DioException) {
        // DEBUG: aniq sababni ko'rsatamiz
        msg = 'Xato turi: ${e.type}\n'
            'Kod: ${e.response?.statusCode ?? "yo\'q"}\n'
            'Xabar: ${e.message ?? friendlyError(e)}';
      } else {
        msg = friendlyError(e);
      }
      _error = msg;
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchMe() async {
    try {
      final res = await _api.dio.get('/auth/me/');
      _me = res.data;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await _api.clearTokens();
    _me = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    _error = null;
    notifyListeners();
  }
}