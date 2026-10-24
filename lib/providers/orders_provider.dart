import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../core/app_dialogs.dart';

/// Buyurtmalar tarixi va chek.
class OrdersProvider extends ChangeNotifier {
  final _api = ApiService.instance;
  List<Order> orders = [];
  bool loading = false;
  String? error;

  Future<void> loadOrders() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _api.dio.get('/orders/');
      // Pagination bo'lsa {'results': [...]}, bo'lmasa to'g'ridan-to'g'ri [...]
      final data = res.data;
      final list = data is List
          ? data
          : (data is Map && data['results'] is List ? data['results'] : []);
      orders = (list as List).map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      debugPrint('loadOrders xato: $e');
      error = friendlyError(e);
    }
    loading = false;
    notifyListeners();
  }

  Future<Order> orderDetail(int id) async {
    final res = await _api.dio.get('/orders/$id/');
    return Order.fromJson(res.data);
  }
}
