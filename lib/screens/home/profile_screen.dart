import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/../onboarding/onboarding_screen.dart';
import '../../services/pin_service.dart';
import 'feedback_screen.dart';

/// Profil — do'kon ma'lumotlari, qarz, fikr, bog'lanish, chiqish.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _adminPhone = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final res = await ApiService.instance.dio.get('/core/config/');
      if (mounted) {
        setState(() => _adminPhone = res.data['admin_phone'] ?? '');
      }
    } catch (_) {}
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.me;
    final shop = me?['shop'];

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Do'kon karta
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.storefront,
                      size: 36, color: AppColors.onPrimary),
                ),
                const SizedBox(height: 12),
                Text(shop?['name'] ?? "Do'kon",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                Text(me?['full_name'] ?? '',
                    style: const TextStyle(color: AppColors.onSurfaceVariant)),
                Text(me?['phone'] ?? '',
                    style: const TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Qarz balansi
          if (shop != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Qarz balansi',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                      formatPrice(double.parse(
                          (shop['debt_balance'] ?? 0).toString())),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),

          // Fikr va takliflar
          _tile(
            icon: Icons.rate_review_outlined,
            title: 'Fikr va takliflar',
            subtitle: 'Ilovani yaxshilash uchun fikr yuboring',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen())),
          ),

          // Biz bilan bog'lanish (admin telefon)
          if (_adminPhone.isNotEmpty)
            _tile(
              icon: Icons.support_agent,
              title: 'Biz bilan bog\'lanish',
              subtitle: _adminPhone,
              trailing: const Icon(Icons.phone, color: AppColors.primary),
              onTap: () => _call(_adminPhone),
            ),

          const SizedBox(height: AppSpacing.md),
          // Chiqish
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Chiqish',
                  style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await auth.logout();
                await PinService.instance.clearPin();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OnboardingScreen()),
                      (r) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppColors.onSurfaceVariant)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}