import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/config.dart';
import '../services/api_service.dart';
import '../services/pin_service.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/no_internet_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/pin_login_screen.dart';
import 'home/main_shell.dart';

/// Boshlang'ich ekran: internet -> majburiy yangilash -> kirish holati.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _noInternet = false;
  bool _retrying = false;
  late final AnimationController _animController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward(); // logo silliq paydo bo'ladi
    _bootstrap();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // Splash kamida 1.5 soniya turadi (logo ko'rinishi uchun)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 0. Internet bormi?
    if (!mounted) return;
    final conn = context.read<ConnectivityProvider>();
    final online = await conn.recheck();
    if (!online) {
      setState(() => _noInternet = true);
      return;
    }

    // 1. Majburiy yangilash
    final updateInfo = await _checkForceUpdate();
    if (updateInfo != null && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => _ForceUpdateScreen(
          apkUrl: updateInfo['apk_url'] ?? '',
          storeUrl: updateInfo['store_url'] ?? '',
          notes: updateInfo['release_notes'] ?? '',
        ),
      ));
      return;
    }

    // 2. Kirish holati
    final auth = context.read<AuthProvider>();
    final loggedIn = await auth.checkLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      // Token bor -> PIN o'rnatilganmi?
      final hasPin = await PinService.instance.hasPin();
      if (hasPin) {
        _go(const PinLoginScreen());
      } else {
        // Token bor lekin PIN yo'q (kamdan-kam holat) -> ichkariga
        await auth.fetchMe();
        _go(const MainShell());
      }
    } else {
      // Birinchi marta -> onboarding -> ro'yxatdan o'tish
      _go(const OnboardingScreen());
    }
  }

  Future<Map<String, dynamic>?> _checkForceUpdate() async {
    try {
      final res = await ApiService.instance.dio.get(
        '/core/app-version/',
        queryParameters: {
          'platform': AppConfig.platform,
          'current': AppConfig.appVersion,
        },
      );
      if (res.data['force_update'] == true) {
        return res.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    final conn = context.read<ConnectivityProvider>();
    final online = await conn.recheck();
    if (online) {
      setState(() {
        _noInternet = false;
        _retrying = false;
      });
      _bootstrap();
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _retrying = false);
    }
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_noInternet) {
      return NoInternetScreen(onRetry: _retry, retrying: _retrying);
    }
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (o'zida DUOO nomi va shiori bor) - silliq paydo bo'ladi
            FadeTransition(
              opacity: _fade,
              child: Image.asset(
                'assets/logo/logo.png',
                width: 240,
                errorBuilder: (_, __, ___) => const Text('DUOO',
                    style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onPrimary)),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.onPrimary),
          ],
        ),
      ),
    );
  }
}

/// Majburiy yangilash — ilovaga kirgizmaydi.
/// "Yangilash" bosilganda APK yoki do'kon havolasini ochadi.
class _ForceUpdateScreen extends StatelessWidget {
  final String apkUrl;
  final String storeUrl;
  final String notes;
  const _ForceUpdateScreen({
    this.apkUrl = '',
    this.storeUrl = '',
    this.notes = '',
  });

  Future<void> _update(BuildContext context) async {
    // APK bo'lsa o'shani, bo'lmasa do'kon havolasini ochamiz
    final target = apkUrl.isNotEmpty ? apkUrl : storeUrl;
    if (target.isEmpty) return;
    final uri = Uri.parse(target);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update,
                  size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text('Yangi versiya chiqdi',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                notes.isNotEmpty
                    ? notes
                    : 'Ilovadan foydalanishni davom ettirish uchun '
                        'yangi versiyani yuklab oling.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _update(context),
                child: const Text('Yangilash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}