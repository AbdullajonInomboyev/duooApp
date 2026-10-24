import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Ilova sozlamalari — bir joyda.
class AppConfig {
  /// Backend manzili — python main.py serveri (IP, HTTP).
  static const String apiBaseUrl = 'http://189.74.100.146/api';

  /// Play Market'dagi ilova identifikatori (android/app/build.gradle.kts).
  static const String androidPackage = 'uz.duoo.app';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackage';

  /// Joriy platforma — majburiy yangilash tekshiruvi uchun.
  static String get platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// Ilova versiyasi pubspec.yaml dagi `version` dan olinadi
  /// (qo'lda yozilgan qiymat bilan farq chiqmasligi uchun).
  static Future<String> appVersion() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      return '0.0.0';
    }
  }
}
