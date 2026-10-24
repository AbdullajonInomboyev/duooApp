import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// Kategoriya, brend, mahsulot — lazy yuklash bilan.
/// Kategoriya tanlanmaguncha uning brendlari yuklanmaydi (yuklamani tejaydi).
/// Mahsulotlar pagination'siz — brend/kategoriya ichidagi hammasi bir marta keladi.
class CatalogProvider extends ChangeNotifier {
  final _api = ApiService.instance;

  List<Category> categories = [];
  List<Brand> brands = [];
  List<Product> products = [];
  bool loading = false;

  /// Serverdan kelgan javobni ro'yxatga aylantiradi.
  /// Pagination bo'lsa {'results': [...]}, bo'lmasa to'g'ridan-to'g'ri [...].
  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  Future<void> loadCategories() async {
    try {
      final res = await _api.dio.get('/categories/');
      categories =
          _asList(res.data).map((e) => Category.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('loadCategories xato: $e');
    }
  }

  Future<void> loadBrands({int? categoryId}) async {
    loading = true;
    notifyListeners();
    try {
      final res = await _api.dio.get('/brands/',
          queryParameters: categoryId != null ? {'category': categoryId} : null);
      brands = _asList(res.data).map((e) => Brand.fromJson(e)).toList();
    } catch (e) {
      debugPrint('loadBrands xato: $e');
      brands = [];
    }
    loading = false;
    notifyListeners();
  }

  /// Brend/kategoriya mahsulotlari — HAMMASI bir marta (pagination yo'q).
  Future<void> loadProducts({int? brandId, int? categoryId}) async {
    loading = true;
    products = [];
    notifyListeners();
    try {
      final params = <String, dynamic>{};
      if (brandId != null) params['brand'] = brandId;
      if (categoryId != null) params['category'] = categoryId;
      final res = await _api.dio.get('/products/', queryParameters: params);
      products = _asList(res.data).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      debugPrint('loadProducts xato: $e');
      products = [];
    }
    loading = false;
    notifyListeners();
  }

  Future<Product> productDetail(int id) async {
    final res = await _api.dio.get('/products/$id/');
    return Product.fromJson(res.data);
  }

  /// Umumiy qidiruv — bosh oyna uchun. Butun katalogdan (nom + brend) qidiradi.
  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _api.dio
        .get('/products/', queryParameters: {'search': query.trim()});
    return _asList(res.data).map((e) => Product.fromJson(e)).toList();
  }
}