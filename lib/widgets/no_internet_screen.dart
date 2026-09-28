import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Internet yo'qligida ko'rsatiladigan chiroyli ekran.
/// "Qayta urinish" tugmasi bilan.
class NoInternetScreen extends StatelessWidget {
  final Future<void> Function() onRetry;
  final bool retrying;
  const NoInternetScreen({
    super.key,
    required this.onRetry,
    this.retrying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikonka doirasi
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_off_rounded,
                      size: 56, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Internet aloqasi yo\'q',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Tarmoqqa ulanishni tekshiring va qaytadan urining.\n'
                  'Wi-Fi yoki mobil internetni yoqing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: retrying ? null : onRetry,
                    icon: retrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.onPrimary))
                        : const Icon(Icons.refresh),
                    label: Text(retrying ? 'Tekshirilmoqda...' : 'Qayta urinish'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kichik banner — ilova ichida internet uzilganda tepada chiqadi.
class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Internet aloqasi yo\'q',
              style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}