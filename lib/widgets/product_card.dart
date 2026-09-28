import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../core/format.dart';
import '../models/models.dart';

/// Mahsulot kartasi (brend mahsulotlari ro'yxatida).
/// Rasm CachedNetworkImage bilan — keshlanadi va lazy yuklanadi.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onTap;
  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasm — yengil, keshlanadigan
            AspectRatio(
              aspectRatio: 1.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: product.image != null
                    ? CachedNetworkImage(
                        imageUrl: product.image!,
                        fit: BoxFit.contain,
                        placeholder: (c, _) => Container(
                          color: AppColors.surfaceDim,
                        ),
                        errorWidget: (c, _, __) => Container(
                          color: AppColors.surfaceDim,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: AppColors.outline),
                        ),
                      )
                    : Container(color: AppColors.surfaceDim),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (product.categoryName != null)
              Text(product.categoryName!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
            Text(product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatPrice(product.price),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark)),
                      Text('/ ${product.unit}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                // "+" tugma yoki "Qolmagan" belgisi
                if (product.inStock)
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAdd,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child:
                            Icon(Icons.add, color: AppColors.onPrimary, size: 24),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text('Qolmagan',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}