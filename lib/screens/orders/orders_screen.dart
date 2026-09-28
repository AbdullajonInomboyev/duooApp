import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../providers/orders_provider.dart';
import 'receipt_screen.dart';

/// Buyurtmalar tarixi — status ranglari bilan (dizayndagi kabi).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final op = context.watch<OrdersProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmalar tarixi')),
      body: op.loading
          ? const Center(child: CircularProgressIndicator())
          : op.orders.isEmpty
              ? const Center(child: Text('Hozircha buyurtmalar yo\'q'))
              : RefreshIndicator(
                  onRefresh: () => op.loadOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: op.orders.length,
                    itemBuilder: (_, i) {
                      final o = op.orders[i];
                      final style = StatusStyle.of(o.status);
                      return GestureDetector(
                        onTap: () async {
                          final detail = await op.orderDetail(o.id);
                          if (context.mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ReceiptScreen(order: detail)));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('№ ${o.receiptNumber}',
                                      style: const TextStyle(
                                          color: AppColors.onSurfaceVariant)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: style.bg,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.full),
                                    ),
                                    child: Text(o.statusDisplay,
                                        style: TextStyle(
                                            color: style.fg,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              const Text('Umumiy summa',
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formatPrice(o.total),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDark)),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.outline),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
