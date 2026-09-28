import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../auth/register_screen.dart';

/// Onboarding — 3 sahifali tanishtiruv (dizayndagi kabi).
/// "O'tkazib yuborish" bilan darhol kirishga o'tadi.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnbData('Xush kelibsiz!',
        "Do'koningiz uchun mahsulotlarni oson buyurtma qiling."),
    _OnbData('Eng yaxshi brendlar va ulgurji narxlar bir joyda.',
        'Keng turdagi mahsulotlarni ishonchli yetkazib berish bilan.'),
    _OnbData('Buyurtmani bering va biz yetkazib beramiz.',
        'Tez, ishonchli va qulay ulgurji xaridlar tizimi.'),
  ];

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _goToRegister();
    }
  }

  void _goToRegister() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToRegister,
                child: const Text("O'tkazib yuborish",
                    style: TextStyle(color: AppColors.primaryDark)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnbPage(data: _pages[i]),
              ),
            ),
            // Nuqtalar (indikator)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_index == _pages.length - 1 ? 'Boshlash' : 'Keyingisi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbData {
  final String title;
  final String subtitle;
  const _OnbData(this.title, this.subtitle);
}

class _OnbPage extends StatelessWidget {
  final _OnbData data;
  const _OnbPage({required this.data});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rasm joyi (assets/images/onboarding_N.png)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(Icons.storefront_outlined,
                size: 80, color: AppColors.outline),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.sm),
          Text(data.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}