import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../providers/catalog_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../catalog/category_brands_screen.dart';
import 'search_screen.dart';

/// Bosh sahifa: DUOO + aloqa telefoni, qidiruv, BANNER SLAYDER, kategoriyalar.
/// Bannerlar admin paneldan keladi — rasm yoki matn (fon rangi bilan), aylanadi.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Oddiy banner modeli (API javobidan).
class _Banner {
  final String title;
  final String subtitle;
  final String? image;
  final String bgColor;
  _Banner({required this.title, required this.subtitle, this.image, required this.bgColor});
  factory _Banner.fromJson(Map j) => _Banner(
        title: (j['title'] ?? '').toString(),
        subtitle: (j['subtitle'] ?? '').toString(),
        image: (j['image'] == null || j['image'].toString().isEmpty)
            ? null
            : j['image'].toString(),
        bgColor: (j['bg_color'] ?? '#009D4D').toString(),
      );
}

class _HomeScreenState extends State<HomeScreen> {
  String _adminPhone = '';
  List<_Banner> _banners = [];
  final _pageCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCategories();
    });
    _loadConfig();
    _loadBanners();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    try {
      final res = await ApiService.instance.dio.get('/core/config/');
      if (mounted) {
        setState(() => _adminPhone = (res.data['admin_phone'] ?? '').toString());
      }
    } catch (_) {}
  }

  Future<void> _loadBanners() async {
    try {
      final res = await ApiService.instance.dio.get('/banners/');
      final data = res.data;
      final list = (data is List) ? data : (data['results'] ?? []);
      if (mounted) {
        setState(() {
          _banners = (list as List).map((e) => _Banner.fromJson(e)).toList();
        });
        _startAuto();
      }
    } catch (_) {}
  }

  // Bir nechta banner bo'lsa, har 4 soniyada avtomatik aylanadi
  void _startAuto() {
    _autoTimer?.cancel();
    if (_banners.length <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageCtrl.hasClients) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Color _hex(String h) {
    try {
      var s = h.replaceAll('#', '').trim();
      if (s.length == 6) s = 'FF$s';
      return Color(int.parse(s, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('DUOO',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        bottom: _adminPhone.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(34),
                child: InkWell(
                  onTap: () => _call(_adminPhone),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 8),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone,
                            size: 15, color: AppColors.primaryDark),
                        const SizedBox(width: 6),
                        Text("Biz bilan bog'lanish: $_adminPhone",
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await catalog.loadCategories();
          await _loadConfig();
          await _loadBanners();
        },
        child: ListView(
          padding: AppSpacing.scroll(context),
          children: [
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
            _buildBanner(),
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
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (_, i) =>
                        _CategoryCard(category: catalog.categories[i]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    // Banner yo'q bo'lsa — standart yashil blok (bo'sh ko'rinmasin)
    if (_banners.isEmpty) {
      return _TextBanner(
        title: 'Ulgurji xaridlar uchun\nmaxsus chegirmalar',
        subtitle: '',
        color: AppColors.primary,
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              if (b.image != null) {
                // Rasm banner
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: CachedNetworkImage(
                    imageUrl: b.image!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        color: AppColors.surfaceDim,
                        child: const Center(
                            child: CircularProgressIndicator())),
                    errorWidget: (_, __, ___) => _TextBanner(
                        title: b.title, subtitle: b.subtitle,
                        color: _hex(b.bgColor)),
                  ),
                );
              }
              // Matn banner
              return _TextBanner(
                  title: b.title, subtitle: b.subtitle, color: _hex(b.bgColor));
            },
          ),
        ),
        // Nuqtalar (bir nechta banner bo'lsa)
        if (_banners.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              final active = i == _bannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Matnli banner (rasm bo'lmaganda) — fon rangi + sarlavha + tavsif.
class _TextBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  const _TextBanner(
      {required this.title, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimary)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.onPrimary, height: 1.3)),
          ],
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
              radius: 32,
              backgroundColor: AppColors.surfaceDim,
              backgroundImage: category.icon != null
                  ? CachedNetworkImageProvider(category.icon!)
                  : null,
              child: category.icon == null
                  ? const Icon(Icons.category, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13, height: 1.2)),
          ],
        ),
      ),
    );
  }
}