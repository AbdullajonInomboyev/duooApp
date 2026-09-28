import 'package:flutter/material.dart';
import 'theme.dart';

/// Ekran o'rtasida chiqadigan xabar oynalari (dialog).
/// "OK" tugmasi bilan yopiladi. Butun ilovada ishlatiladi.
class AppDialogs {
  /// Xato xabari — qizil ikonka, "OK" tugmasi.
  static Future<void> error(BuildContext context, String message) {
    return _show(context, message,
        icon: Icons.error_outline, color: AppColors.error);
  }

  /// Muvaffaqiyat xabari — yashil ikonka.
  static Future<void> success(BuildContext context, String message) {
    return _show(context, message,
        icon: Icons.check_circle_outline, color: AppColors.success);
  }

  /// Ogohlantirish — sariq ikonka.
  static Future<void> info(BuildContext context, String message) {
    return _show(context, message,
        icon: Icons.info_outline, color: AppColors.warning);
  }

  static Future<void> _show(BuildContext context, String message,
      {required IconData icon, required Color color}) {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: color),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dio xatolarini o'zbekcha, aniq matnga aylantiradi.
/// Har holatga mos xabar — "Xatolik" degan quruq so'z emas.
String friendlyError(Object e) {
  final s = e.toString().toLowerCase();

  // Tarmoq
  if (s.contains('socketexception') ||
      s.contains('failed host lookup') ||
      s.contains('network') ||
      s.contains('connection refused') ||
      s.contains('connection error')) {
    return 'Internet aloqasi yo\'q. Tarmoqni tekshiring.';
  }
  if (s.contains('timeout')) {
    return 'Server javob bermadi. Qaytadan urining.';
  }
  // Server xatosi
  if (s.contains('500') || s.contains('502') || s.contains('503')) {
    return 'Serverda vaqtincha nosozlik. Birozdan so\'ng urining.';
  }
  if (s.contains('413')) {
    return 'Yuklangan rasm juda katta. Kichikroq rasm tanlang.';
  }
  if (s.contains('401') || s.contains('403')) {
    return 'Sessiya tugadi. Qaytadan kiring.';
  }
  if (s.contains('404')) {
    return 'Ma\'lumot topilmadi.';
  }
  return 'Xatolik yuz berdi. Qaytadan urining.';
}