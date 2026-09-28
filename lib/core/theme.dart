import 'package:flutter/material.dart';

/// DUOO dizayn tizimi.
/// Uch rang qoidasi: OQ fon, YASHIL brend (#009D4D), QORA matn.
/// Matn rangi fonga qarab: oq fonda qora, yashil fonda oq.
/// Status uchun 3 rang (yashil/sariq/qizil) + ikonka bilan farqlanadi.
class AppColors {
  // Brend
  static const primary = Color(0xFF009D4D);        // asosiy yashil
  static const primaryDark = Color(0xFF006D35);    // to'q yashil (narx, aksent)
  static const onPrimary = Color(0xFFFFFFFF);      // yashil ustidagi matn (OQ)

  // Fon va yuzalar
  static const background = Color(0xFFF9F9F9);      // asosiy fon (deyarli oq)
  static const surface = Color(0xFFFFFFFF);         // kartalar (oq)
  static const surfaceDim = Color(0xFFF3F3F3);      // ikkilamchi fon

  // Matn (oq fonda)
  static const onSurface = Color(0xFF1A1C1C);       // asosiy matn (qora)
  static const onSurfaceVariant = Color(0xFF5F5F5F); // ikkilamchi matn (kulrang)
  static const outline = Color(0xFF9E9E9E);         // chegara
  static const outlineVariant = Color(0xFFE0E0E0);  // yengil chegara

  // Status ranglari (FAQAT status belgilari uchun, ikonka bilan birga)
  static const success = Color(0xFF009D4D);         // ✓ yetkazildi/to'landi (yashil)
  static const successBg = Color(0xFFE6F5EC);
  static const warning = Color(0xFFF9A825);         // ⏱ kutilmoqda (sariq)
  static const warningBg = Color(0xFFFFF8E1);
  static const error = Color(0xFFD32F2F);           // ✕ bekor qilindi (qizil)
  static const errorBg = Color(0xFFFDECEA);
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;   // input, kichik tugma
  static const lg = 16.0;
  static const xl = 24.0;   // asosiy kartalar
  static const full = 999.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;   // gutter
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Ilovaning umumiy mavzusi.
ThemeData buildAppTheme() {
  const fontFamily = 'PlusJakartaSans';

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.onSurface,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.onSurface),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
    // Asosiy tugma: yashil fon, oq matn, 56px balandlik.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}

/// Buyurtma statusiga rang + ikonka beruvchi yordamchi.
class StatusStyle {
  final Color fg;
  final Color bg;
  final IconData icon;
  const StatusStyle(this.fg, this.bg, this.icon);

  static StatusStyle of(String status) {
    switch (status) {
      case 'delivered':
      case 'paid':
        return const StatusStyle(
            AppColors.success, AppColors.successBg, Icons.check_circle);
      case 'cancelled':
        return const StatusStyle(
            AppColors.error, AppColors.errorBg, Icons.cancel);
      case 'new':
      case 'confirmed':
      case 'packed':
      case 'on_the_way':
      default:
        return const StatusStyle(
            AppColors.warning, AppColors.warningBg, Icons.schedule);
    }
  }
}