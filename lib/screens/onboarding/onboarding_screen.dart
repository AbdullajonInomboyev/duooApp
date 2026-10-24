import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_choice_screen.dart';

/// SharedPreferences kaliti: onboarding ko'rilganmi.
const onboardingSeenKey = 'onboarding_seen';

/// Onboarding — 3 sahifali tanishtiruv. Har sahifada rasm + sarlavha + matn.
/// "O'tkazib yuborish" yoki "Boshlash" -> "Hisobingiz bormi?" oynasi.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  // Har sahifa: illyustratsiya + sarlavha + matn
  final _pages = const [
    _OnbData(
      'assets/images/onboarding_1.svg',
      'Xush kelibsiz!',
      "Do'koningiz uchun mahsulotlarni oson buyurtma qiling.",
    ),
    _OnbData(
      'assets/images/onboarding_2.svg',
      'Eng yaxshi brendlar va ulgurji narxlar bir joyda.',
      'Keng turdagi mahsulotlarni ishonchli yetkazib berish bilan.',
    ),
    _OnbData(
      'assets/images/onboarding_3.svg',
      'Buyurtmani bering va biz yetkazib beramiz.',
      'Tez, ishonchli va qulay ulgurji xaridlar tizimi.',
    ),
  ];

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _goToRegister();
    }
  }

  /// Onboarding bir marta ko'rsatiladi, keyin "Hisobingiz bormi?" oynasi.
  Future<void> _goToRegister() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingSeenKey, true);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen()));
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
                child:
                    Text(_index == _pages.length - 1 ? 'Boshlash' : 'Keyingisi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbData {
  final String image;
  final String title;
  final String subtitle;
  const _OnbData(this.image, this.title, this.subtitle);
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
          // Illyustratsiya — assets/images/onboarding_N.svg (vektor, har
          // qanday ekranda tiniq)
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: AspectRatio(
                aspectRatio: 360 / 300,
                child: SvgPicture.asset(data.image, fit: BoxFit.contain),
              ),
            ),
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