import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/models.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';

/// Mahsulot tafsiloti — to'liq rasm, tavsif, miqdor, savatga qo'shish.
class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await context.read<CatalogProvider>().productDetail(widget.productId);
    setState(() => _product = p);
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    return Scaffold(
      appBar: AppBar(title: const Text('Tafsilotlar')),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: p.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            child: CachedNetworkImage(
                                imageUrl: p.image!, fit: BoxFit.contain),
                          )
                        : const Icon(Icons.image_outlined,
                            size: 80, color: AppColors.outline),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (p.categoryName != null)
                    Text(p.categoryName!.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                  Text(p.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(formatPrice(p.price),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                  const Divider(height: 32),
                  const Text('Tavsif',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(p.description ?? '—',
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, height: 1.5)),
                ],
              ),
            ),
      bottomNavigationBar: p == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Miqdor tanlagich
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDim,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () =>
                                  setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                              icon: const Icon(Icons.remove)),
                          Text('$_qty',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          IconButton(
                              onPressed: () => setState(() => _qty++),
                              icon: const Icon(Icons.add)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context
                              .read<CartProvider>()
                              .setItem(p.id, _qty);
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Savatga qo\'shish'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
