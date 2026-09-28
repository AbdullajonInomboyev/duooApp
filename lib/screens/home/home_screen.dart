import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../providers/catalog_provider.dart';
import '../../models/models.dart';
import '../catalog/category_brands_screen.dart';
import 'search_screen.dart';

/// Bosh sahifa: qidiruv, banner, KATEGORIYALAR (kategoriya -> brend -> mahsulot).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('DUOO')),
      body: RefreshIndicator(
        onRefresh: () => catalog.loadCategories(),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Qidiruv - bosilsa umumiy qidiruv ekrani ochiladi
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Mahsulot qidirish...',
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ulgurji xaridlar uchun\nmaxsus chegirmalar',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Kategoriyalar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.md),
            catalog.loading && catalog.categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catalog.categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (_, i) =>
                        _CategoryCard(category: catalog.categories[i]),
                  ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  const _CategoryCard({required this.category});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CategoryBrandsScreen(category: category)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.surfaceDim,
              backgroundImage: category.icon != null
                  ? CachedNetworkImageProvider(category.icon!)
                  : null,
              child: category.icon == null
                  ? const Icon(Icons.category, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}