import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import 'order_success_screen.dart';
import '../../core/app_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buyurtmani tasdiqlash — tarkib, to'lov turi, tasdiqlash.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _payment = 'cash';
  bool _submitting = false;

  final _payments = const {
    'cash': 'Naqd pul',
    'credit': 'Nasiya',
    'transfer': "O'tkazma",
  };

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    final cart = context.read<CartProvider>();
    final order = await cart.checkout(paymentType: _payment);
    if (!mounted) return;
    if (order != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(order: order)));
    } else {
      setState(() => _submitting = false);
      final err = cart.lastError ?? 'Buyurtma yaratishda xatolik';
      // Tasdiqlanmagan bo'lsa — admin bilan bog'lanish oynasi
      if (err.contains('tasdiqlanmagan')) {
        _showApprovalDialog(err);
      } else {
        AppDialogs.error(context, err);
      }
    }
  }

  /// Tasdiqlanmagan do'kon uchun — admin raqamiga qo'ng'iroq qilish oynasi.
  void _showApprovalDialog(String message) {
    // Xabardan telefon raqamini ajratib olamiz
    final phoneMatch = RegExp(r'\+?\d[\d\s]{7,}').firstMatch(message);
    final phone = phoneMatch?.group(0)?.replaceAll(' ', '') ?? '';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 56, color: AppColors.warning),
              const SizedBox(height: AppSpacing.md),
              const Text('Hisobingiz tasdiqlanmagan',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Birinchi buyurtma uchun administrator tasdig\'i kerak. '
                'Iltimos, administrator bilan bog\'laning:',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(phone,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (phone.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Qo\'ng\'iroq qilish'),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Yopish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmani tasdiqlash')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BUYURTMA TARKIBI',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                ...cart.items.map((i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(i.productName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    '${i.quantity} ${i.unit} x ${formatPrice(i.price)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Text(formatPrice(i.lineTotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // To'lov turi
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              children: _payments.entries
                  .map((e) => RadioListTile<String>(
                        value: e.key,
                        groupValue: _payment,
                        onChanged: (v) => setState(() => _payment = v!),
                        title: Text(e.value),
                        activeColor: AppColors.primaryDark,
                        contentPadding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jami:',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(formatPrice(cart.total),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitting ? null : _confirm,
                child: _submitting
                    ? const CircularProgressIndicator()
                    : const Text('Tasdiqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}