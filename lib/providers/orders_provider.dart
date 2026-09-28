import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// Buyurtmalar tarixi va chek.
class OrdersProvider extends ChangeNotifier {
  final _api = ApiService.instance;
  List<Order> orders = [];
  bool loading = false;

  Future<void> loadOrders() async {
    loading = true;
    notifyListeners();
    final res = await _api.dio.get('/orders/');
    orders = (res.data['results'] as List)
        .map((e) => Order.fromJson(e))
        .toList();
    loading = false;
    notifyListeners();
  }

  Future<Order> orderDetail(int id) async {
    final res = await _api.dio.get('/orders/$id/');
    return Order.fromJson(res.data);
  }
}
