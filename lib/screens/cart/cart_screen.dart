import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

/// Savat — miqdorni o'zgartirish, o'chirish, buyurtma xulosasi.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savat'),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: AppColors.outline),
                  SizedBox(height: 16),
                  Text('Savat bo\'sh',
                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                ],
              ),
            )
          : ListView(
              padding: AppSpacing.scroll(context),
              children: [
                Text('Sizning tanlangan mahsulotlaringiz (${cart.itemCount} ta)',
                    style: const TextStyle(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.md),
                ...cart.items.map((item) => Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(item.productName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.outline),
                                onPressed: () =>
                                    cart.setItem(item.product, 0),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Miqdor
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDim,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () => cart.setItem(
                                            item.product, item.quantity - 1),
                                        icon: const Icon(Icons.remove)),
                                    Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    IconButton(
                                        onPressed: () => cart.setItem(
                                            item.product, item.quantity + 1),
                                        icon: const Icon(Icons.add)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      '${item.quantity} ${item.unit} x ${formatPrice(item.price)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.onSurfaceVariant)),
                                  Text(formatPrice(item.lineTotal),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDark)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                // Buyurtma xulosasi
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    children: [
                      const Text('Buyurtma xulosasi',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const Divider(height: 24),
                      _row('Mahsulotlar soni', '${cart.itemCount} ta'),
                      _row('Yetkazib berish', 'Bepul'),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jami summa:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          Text(formatPrice(cart.total),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CheckoutScreen())),
                        child: const Text('Buyurtma berish'),
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
