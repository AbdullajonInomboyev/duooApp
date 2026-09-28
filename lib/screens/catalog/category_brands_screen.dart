import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/catalog_provider.dart';
import 'brand_products_screen.dart';

/// Bir kategoriyaning brendlari — SATR (ro'yxat) ko'rinishida + qidiruv.
class CategoryBrandsScreen extends StatefulWidget {
  final Category category;
  const CategoryBrandsScreen({super.key, required this.category});
  @override
  State<CategoryBrandsScreen> createState() => _CategoryBrandsScreenState();
}

class _CategoryBrandsScreenState extends State<CategoryBrandsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadBrands(categoryId: widget.category.id);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    // Qidiruv: nom ichidan ham topadi (kichik/katta harf farqsiz)
    final brands = _query.isEmpty
        ? catalog.brands
        : catalog.brands
            .where((b) => b.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Column(
        children: [
          // Qidiruv maydoni
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Brend qidirish...',
                filled: true,
                fillColor: AppColors.surface,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: catalog.loading
                ? const Center(child: CircularProgressIndicator())
                : brands.isEmpty
                    ? const Center(
                        child: Text('Brend topilmadi',
                            style: TextStyle(color: AppColors.onSurfaceVariant)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        itemCount: brands.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) {
                          final b = brands[i];
                          return _BrandRow(
                            brand: b,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => BrandProductsScreen(
                                          brand: b,
                                          category: widget.category,
                                        ))),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Bitta brend — satr ko'rinishida (rasm chapda, nom o'rtada, strelka o'ngda).
class _BrandRow extends StatelessWidget {
  final Brand brand;
  final VoidCallback onTap;
  const _BrandRow({required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // Rasm — kichik border radius, ichida to'liq ko'rinadi
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppColors.surfaceDim,
                  child: brand.logo != null
                      ? CachedNetworkImage(
                          imageUrl: brand.logo!,
                          fit: BoxFit.contain, // to'liq ko'rinsin (kesilmasin)
                          placeholder: (_, __) => const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))),
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.business, color: AppColors.outline),
                        )
                      : const Icon(Icons.business, color: AppColors.outline),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(brand.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}