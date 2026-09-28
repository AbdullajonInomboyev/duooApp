import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/models.dart';
import '../../providers/catalog_provider.dart';
import '../catalog/product_detail_screen.dart';

/// Umumiy qidiruv — butun katalogdan mahsulot qidiradi.
/// Natijani bossa, mahsulot ichiga kiradi.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Product> _results = [];
  bool _loading = false;
  bool _searched = false;

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    // Yozishni to'xtatgach 400ms keyin qidiradi (server yukini kamaytiradi)
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(v));
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final res =
          await context.read<CatalogProvider>().searchProducts(query);
      if (mounted) {
        setState(() {
          _results = res;
          _loading = false;
          _searched = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _searched = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Mahsulot qidirish...',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                _onChanged('');
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_searched
              ? const Center(
                  child: Text('Mahsulot nomini yozing',
                      style: TextStyle(color: AppColors.onSurfaceVariant)))
              : _results.isEmpty
                  ? const Center(
                      child: Text('Hech narsa topilmadi',
                          style:
                              TextStyle(color: AppColors.onSurfaceVariant)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        final p = _results[i];
                        return Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(productId: p.id))),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      color: AppColors.surfaceDim,
                                      child: p.image != null
                                          ? CachedNetworkImage(
                                              imageUrl: p.image!,
                                              fit: BoxFit.contain,
                                              errorWidget: (_, __, ___) =>
                                                  const Icon(
                                                      Icons
                                                          .inventory_2_outlined,
                                                      color: AppColors.outline),
                                            )
                                          : const Icon(
                                              Icons.inventory_2_outlined,
                                              color: AppColors.outline),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text(formatPrice(p.price),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primaryDark)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.outline),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}