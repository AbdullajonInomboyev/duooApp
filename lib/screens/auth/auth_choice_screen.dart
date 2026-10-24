import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// "Hisobingiz bormi?" — onboarding'dan keyin.
/// Hisobi borlar telefon+parol bilan kiradi, yangilar ro'yxatdan o'tadi.
class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo (yashil doira ichida — oq logo)
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/logo/logo_mark_white.png',
                    errorBuilder: (_, __, ___) => const Icon(Icons.storefront,
                        color: AppColors.onPrimary, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Hisobingiz bormi?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                "Avval ro'yxatdan o'tgan bo'lsangiz, telefon raqam va "
                "parolingiz bilan kiring. Birinchi marta bo'lsa — "
                "do'koningizni ro'yxatdan o'tkazing.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, height: 1.5),
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Ha, hisobimga kirish'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text("Yo'q, ro'yxatdan o'tish"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
