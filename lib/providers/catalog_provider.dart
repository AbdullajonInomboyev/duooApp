import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// Kategoriya, brend, mahsulot — lazy yuklash bilan.
/// Kategoriya tanlanmaguncha uning brendlari yuklanmaydi (yuklamani tejaydi).
class CatalogProvider extends ChangeNotifier {
  final _api = ApiService.instance;

  List<Category> categories = [];
  List<Brand> brands = [];
  List<Product> products = [];
  bool loading = false;

  // Pagination holati
  int _page = 1;
  bool _hasMore = true;
  int? _currentBrand;
  int? _currentCategory;

  Future<void> loadCategories() async {
    final res = await _api.dio.get('/categories/');
    categories = (res.data as List).map((e) => Category.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> loadBrands({int? categoryId}) async {
    loading = true;
    notifyListeners();
    final res = await _api.dio.get('/brands/',
        queryParameters: categoryId != null ? {'category': categoryId} : null);
    brands = (res.data as List).map((e) => Brand.fromJson(e)).toList();
    loading = false;
    notifyListeners();
  }

  /// Brend mahsulotlari — birinchi sahifa.
  Future<void> loadProducts({int? brandId, int? categoryId}) async {
    loading = true;
    _page = 1;
    _hasMore = true;
    _currentBrand = brandId;
    _currentCategory = categoryId;
    products = [];
    notifyListeners();

    final params = <String, dynamic>{'page': 1};
    if (brandId != null) params['brand'] = brandId;
    if (categoryId != null) params['category'] = categoryId;

    final res = await _api.dio.get('/products/', queryParameters: params);
    products = (res.data['results'] as List)
        .map((e) => Product.fromJson(e))
        .toList();
    _hasMore = res.data['next'] != null;
    loading = false;
    notifyListeners();
  }

  /// Keyingi sahifa — pastga scroll qilinganda (lazy loading).
  Future<void> loadMore() async {
    if (!_hasMore || loading) return;
    loading = true;
    notifyListeners();
    _page++;
    final params = <String, dynamic>{'page': _page};
    if (_currentBrand != null) params['brand'] = _currentBrand;
    if (_currentCategory != null) params['category'] = _currentCategory;
    final res = await _api.dio.get('/products/', queryParameters: params);
    products.addAll((res.data['results'] as List).map((e) => Product.fromJson(e)));
    _hasMore = res.data['next'] != null;
    loading = false;
    notifyListeners();
  }

  Future<Product> productDetail(int id) async {
    final res = await _api.dio.get('/products/$id/');
    return Product.fromJson(res.data);
  }

  /// Umumiy qidiruv — bosh oyna uchun. Butun katalogdan (nom + brend)
  /// qidiradi. Alohida ro'yxat qaytaradi (asosiy 'products' ga tegmaydi).
  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _api.dio
        .get('/products/', queryParameters: {'search': query.trim()});
    return (res.data['results'] as List)
        .map((e) => Product.fromJson(e))
        .toList();
  }
}