import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:godostavka_store/core/format.dart';
import 'package:godostavka_store/core/theme.dart';

void main() {
  test('narx so\'m bilan formatlanadi', () {
    final text = formatPrice(216000);
    expect(text.endsWith("so'm"), isTrue);
    expect(text.replaceAll(RegExp(r'\s'), ''), "216000so'm");
  });

  test('buyurtma statusi rangi', () {
    expect(StatusStyle.of('delivered').fg, AppColors.success);
    expect(StatusStyle.of('cancelled').fg, AppColors.error);
    expect(StatusStyle.of('new').fg, AppColors.warning);
  });

  testWidgets('scroll padding pastki tizim panelini hisobga oladi',
      (tester) async {
    late EdgeInsets padding;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
      child: Builder(builder: (context) {
        padding = AppSpacing.scroll(context);
        return const SizedBox();
      }),
    ));
    expect(padding.bottom, AppSpacing.md + 24);
    expect(padding.top, AppSpacing.md);
  });
}
