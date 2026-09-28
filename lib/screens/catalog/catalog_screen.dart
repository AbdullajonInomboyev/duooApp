import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/catalog_provider.dart';
import 'category_brands_screen.dart';

/// Katalog — kategoriyalar (bo'limlar) ro'yxati.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CatalogProvider>().categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final c = categories[i];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              leading: const CircleAvatar(
                backgroundColor: AppColors.surfaceDim,
                child: Icon(Icons.category_outlined, color: AppColors.primaryDark),
              ),
              title: Text(c.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CategoryBrandsScreen(category: c))),
            ),
          );
        },
      ),
    );
  }
}
