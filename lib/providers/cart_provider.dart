import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../core/app_dialogs.dart';

/// Savat holati. Server bilan sinxron ishlaydi.
/// Xato bo'lsa aniq matn (lastError) saqlanadi — ekran uni dialogda ko'rsatadi.
class CartProvider extends ChangeNotifier {
  final _api = ApiService.instance;

  List<CartItem> items = [];
  double total = 0;
  bool loading = false;
  String? lastError;

  int get itemCount => items.length;

  Future<void> loadCart() async {
    try {
      final res = await _api.dio.get('/cart/');
      _parse(res.data);
    } catch (_) {
      // Savat yuklanmasa jim (bo'sh ko'rsatamiz)
    }
  }

  /// Mahsulot qo'shish yoki miqdorni yangilash.
  /// quantity=0 -> savatdan o'chiriladi.
  /// Muvaffaqiyat: true. Xato: false + lastError to'ladi.
  Future<bool> setItem(int productId, int quantity) async {
    lastError = null;
    try {
      final res = await _api.dio.post('/cart/', data: {
        'product': productId,
        'quantity': quantity,
      });
      _parse(res.data);
      return true;
    } catch (e) {
      // Serverdan aniq sabab kelsa o'shani, bo'lmasa umumiy tarmoq xatosi
      lastError = _serverMessage(e) ?? friendlyError(e);
      return false;
    }
  }

  int quantityOf(int productId) {
    final match = items.where((e) => e.product == productId);
    return match.isEmpty ? 0 : match.first.quantity;
  }

  Future<void> clear() async {
    try {
      await _api.dio.delete('/cart/');
    } catch (_) {}
    items = [];
    total = 0;
    notifyListeners();
  }

  /// Buyurtma rasmiylashtirish -> chek qaytadi. Xato bo'lsa null + lastError.
  Future<Order?> checkout({String paymentType = 'cash'}) async {
    lastError = null;
    try {
      final res = await _api.dio.post('/orders/', data: {
        'payment_type': paymentType,
      });
      items = [];
      total = 0;
      notifyListeners();
      return Order.fromJson(res.data);
    } catch (e) {
      lastError = _serverMessage(e) ?? friendlyError(e);
      return null;
    }
  }

  /// Serverdan kelgan aniq xato matnini oladi (masalan "Mahsulot qolmagan").
  String? _serverMessage(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.isNotEmpty) {
        final val = data.values.first;
        final text = val is List ? val.first.toString() : val.toString();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }

  void _parse(dynamic data) {
    if (data is Map && data['items'] is List) {
      items = (data['items'] as List).map((e) => CartItem.fromJson(e)).toList();
      total = double.tryParse(data['total'].toString()) ?? 0;
    } else {
      items = [];
      total = 0;
    }
    notifyListeners();
  }
}