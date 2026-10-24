import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../core/app_dialogs.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/auth_choice_screen.dart';
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
  String _privacyUrl = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final res = await ApiService.instance.dio.get('/core/config/');
      if (mounted) {
        setState(() {
          _adminPhone = res.data['admin_phone'] ?? '';
          _privacyUrl = res.data['privacy_policy_url'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Hisobni o'chirish — tasdiqlash oynasi, keyin serverga so'rov.
  Future<void> _confirmDelete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text("Hisobni o'chirish"),
        content: const Text(
            "Hisobingiz, do'kon ma'lumotlari va buyurtmalar tarixi butunlay "
            "o'chiriladi. Bu amalni qaytarib bo'lmaydi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("O'chirish",
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount();
    await PinService.instance.clearPin();
    if (!mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
          (r) => false);
    } else {
      AppDialogs.error(context, auth.error ?? "Hisobni o'chirib bo'lmadi");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.me;
    final shop = me?['shop'];

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: AppSpacing.scroll(context),
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

          // Maxfiylik siyosati (server sozlamasida havola bo'lsa)
          if (_privacyUrl.isNotEmpty)
            _tile(
              icon: Icons.privacy_tip_outlined,
              title: 'Maxfiylik siyosati',
              subtitle: "Ma'lumotlaringiz qanday ishlatiladi",
              onTap: () => _openUrl(_privacyUrl),
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
                          builder: (_) => const AuthChoiceScreen()),
                      (r) => false);
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Hisobni o'chirish (Google Play talabi)
          Center(
            child: TextButton(
              onPressed: auth.loading ? null : _confirmDelete,
              child: const Text("Hisobni o'chirish",
                  style: TextStyle(color: AppColors.onSurfaceVariant)),
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