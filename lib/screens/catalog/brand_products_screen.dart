import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/models.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/app_dialogs.dart';
import 'product_detail_screen.dart';
import '../cart/cart_screen.dart';

/// Brend mahsulotlari — SATR ko'rinishida + qidiruv.
/// "+" bilan savatga qo'shish, pastda umumiy summa.
class BrandProductsScreen extends StatefulWidget {
  final Brand brand;
  final Category? category;
  const BrandProductsScreen({super.key, required this.brand, this.category});
  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    context.read<CatalogProvider>().loadProducts(
          brandId: widget.brand.id,
          categoryId: widget.category?.id,
        );
  }

  Future<void> _add(Product p, CartProvider cart) async {
    final current = cart.quantityOf(p.id);
    final ok = await cart.setItem(p.id, current + 1);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${p.name} savatga qo\'shildi'),
        duration: const Duration(milliseconds: 900),
      ));
    } else {
      AppDialogs.error(context, cart.lastError ?? 'Xatolik yuz berdi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cart = context.watch<CartProvider>();

    // Qidiruv (nom ichidan)
    final products = _query.isEmpty
        ? catalog.products
        : catalog.products
            .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.brand.name)),
      body: Column(
        children: [
          // Qidiruv
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Mahsulot qidirish...',
                filled: true,
                fillColor: AppColors.surface,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: catalog.loading && catalog.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(
                        child: Text('Mahsulot topilmadi',
                            style:
                                TextStyle(color: AppColors.onSurfaceVariant)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) {
                          final p = products[i];
                          return _ProductRow(
                            product: p,
                            onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(
                                            productId: p.id)))
                                .then((_) => _reload()),
                            onAdd: () => _add(p, cart),
                          );
                        },
                      ),
          ),
        ],
      ),
      // Pastda "Savatga o'tish" (savatda mahsulot bo'lsa)
      bottomNavigationBar: cart.itemCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CartScreen()))
                      .then((_) => _reload()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Savatga o\'tish (${cart.itemCount})'),
                      Text(formatPrice(cart.total)),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// Bitta mahsulot — satr: rasm chapda, nom+narx o'rtada, "+" o'ngda.
class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const _ProductRow(
      {required this.product, required this.onTap, required this.onAdd});

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
              // Rasm — to'liq ko'rinsin (contain), kichik radius
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surfaceDim,
                  child: product.image != null
                      ? CachedNetworkImage(
                          imageUrl: product.image!,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))),
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.outline),
                        )
                      : const Icon(Icons.inventory_2_outlined,
                          color: AppColors.outline),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Nom + narx
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(formatPrice(product.price),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // "+" tugma — ombor doim to'la, har doim ko'rinadi
              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAdd,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add,
                        color: AppColors.onPrimary, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}