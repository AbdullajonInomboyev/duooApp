import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  // Dio xatolari — aniq turi bo'yicha (ishonchli)
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Server javob bermadi. Internet sekin yoki server band. Qaytadan urining.';
      case DioExceptionType.connectionError:
        return 'Internet aloqasi yo\'q. Tarmoqni tekshiring.';
      case DioExceptionType.badCertificate:
        return 'Xavfsizlik sertifikati muammosi. Keyinroq urining.';
      case DioExceptionType.cancel:
        return 'So\'rov bekor qilindi.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 413) return 'Do\'kon rasmi juda katta. Kichikroq rasm tanlang.';
        if (code == 401 || code == 403) return 'Ruxsat yo\'q yoki sessiya tugadi.';
        if (code == 404) return 'Ma\'lumot topilmadi.';
        if (code == 429) return 'Juda ko\'p urinish. Birozdan so\'ng qaytadan urining.';
        if (code >= 500) return 'Serverda vaqtincha nosozlik. Birozdan so\'ng urining.';
        return 'So\'rovda xatolik (kod: $code).';
      case DioExceptionType.unknown:
        final s = e.message?.toLowerCase() ?? '';
        if (s.contains('socket') || s.contains('network') ||
            s.contains('failed host')) {
          return 'Internet aloqasi yo\'q. Tarmoqni tekshiring.';
        }
        return 'Tarmoq xatosi. Internetni tekshirib, qaytadan urining.';
      default:
        return 'Tarmoq xatosi. Internetni tekshirib, qaytadan urining.';
    }
  }
  // Dio bo'lmagan xatolar
  final s = e.toString().toLowerCase();
  if (s.contains('socket') || s.contains('network') ||
      s.contains('failed host') || s.contains('connection')) {
    return 'Internet aloqasi yo\'q. Tarmoqni tekshiring.';
  }
  if (s.contains('timeout')) {
    return 'Server javob bermadi. Qaytadan urining.';
  }
  return 'Xatolik yuz berdi. Qaytadan urining.';
}