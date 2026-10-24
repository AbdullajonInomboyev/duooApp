import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// PIN klaviaturasi (dizayndagi kabi) — o'rnatish va kiritishда qayta ishlatiladi.
class PinPad extends StatelessWidget {
  final String title;
  final String subtitle;
  final int filledCount;
  final String? error;
  final void Function(String) onKey;
  final VoidCallback onDelete;
  final Widget? footer;

  const PinPad({
    super.key,
    required this.title,
    required this.subtitle,
    required this.filledCount,
    required this.onKey,
    required this.onDelete,
    this.error,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Logo doirasi (yashil)
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/logo/logo_mark_white.png',
              errorBuilder: (_, __, ___) => const Icon(Icons.storefront,
                  color: AppColors.onPrimary, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          Text(title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 32),
          // 4 nuqta
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < filledCount;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                      color: filled ? AppColors.primary : AppColors.outline,
                      width: 2),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Xato matni
          SizedBox(
            height: 24,
            child: error != null
                ? Text(error!,
                    style: const TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600))
                : null,
          ),
          const SizedBox(height: 16),
          // Raqamli klaviatura
          _buildKeypad(),
          if (footer != null) ...[const SizedBox(height: 16), footer!],
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: SizedBox(
              width: 72,
              height: 64,
              child: Center(
                child: child ??
                    Text(label,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          key('1', onTap: () => onKey('1')),
          key('2', onTap: () => onKey('2')),
          key('3', onTap: () => onKey('3')),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          key('4', onTap: () => onKey('4')),
          key('5', onTap: () => onKey('5')),
          key('6', onTap: () => onKey('6')),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          key('7', onTap: () => onKey('7')),
          key('8', onTap: () => onKey('8')),
          key('9', onTap: () => onKey('9')),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // bo'sh joy
          const SizedBox(width: 88),
          key('0', onTap: () => onKey('0')),
          key('', onTap: onDelete, child: const Icon(Icons.backspace_outlined)),
        ]),
      ],
    );
  }
}