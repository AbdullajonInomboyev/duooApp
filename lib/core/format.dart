import 'package:intl/intl.dart';

/// Narxni "216 000 so'm" ko'rinishida formatlash.
String formatPrice(double value) {
  final f = NumberFormat('#,###', 'ru'); // bo'shliq bilan ajratadi
  return "${f.format(value).replaceAll(',', ' ')} so'm";
}

/// Sanani "27-Avgust, 2026 • 14:30" ko'rinishida.
String formatDateTime(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('dd.MM.yyyy • HH:mm').format(dt);
  } catch (_) {
    return iso;
  }
}
