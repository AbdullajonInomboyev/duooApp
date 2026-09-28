import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/models.dart';
import '../home/main_shell.dart';
import '../orders/receipt_screen.dart';

/// Muvaffaqiyatli buyurtma — chek raqami bilan (dizayndagi kabi).
class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check,
                    size: 48, color: AppColors.onPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Buyurtmangiz qabul qilindi!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text(
                'Sizning buyurtmangiz muvaffaqiyatli rasmiylashtirildi. '
                'Tez orada menejerlarimiz siz bilan bog\'lanadi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    _row('BUYURTMA RAQAMI', order.receiptNumber),
                    const SizedBox(height: 8),
                    _row('SANA VA VAQT', formatDateTime(order.createdAt)),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReceiptScreen(order: order))),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Chekni ko\'rish'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (r) => false),
                child: const Text('Bosh sahifaga qaytish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String r) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.onSurfaceVariant)),
          Text(r, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );
}
