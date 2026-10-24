import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/models.dart';

/// Chek tafsilotlari (dizayndagi kabi).
class ReceiptScreen extends StatelessWidget {
  final Order order;
  const ReceiptScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chek'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: ListView(
        padding: AppSpacing.scroll(context),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long,
                      color: AppColors.onPrimary),
                ),
                const SizedBox(height: 12),
                Text(order.shopName ?? "Do'kon",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Chek № ${order.receiptNumber}',
                    style: const TextStyle(color: AppColors.onSurfaceVariant)),
                Text(formatDateTime(order.createdAt),
                    style: const TextStyle(color: AppColors.onSurfaceVariant)),
                const Divider(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('MAHSULOTLAR',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant)),
                ),
                const SizedBox(height: 12),
                ...order.items.map((i) => Padding(
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
                                    '${i.quantity} ${i.unit} x ${formatPrice(i.unitPrice)}',
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
                const Divider(height: 32),
                _row('Oraliq summa', formatPrice(order.itemsTotal)),
                _row('Yetkazib berish', formatPrice(order.deliveryFee)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jami summa',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(formatPrice(order.total),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: const TextStyle(color: AppColors.onSurfaceVariant)),
            Text(r, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
