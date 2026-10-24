import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/pin_service.dart';
import '../../providers/auth_provider.dart';
import '../home/main_shell.dart';
import 'pin_widgets.dart';
import 'pin_reset_screen.dart';
import 'auth_choice_screen.dart';

/// PIN kiritish — ilova qayta ochilganda (kirish).
/// To'g'ri PIN -> ichkariga. 5 marta xato -> chiqib ketadi.
/// "PIN unutdingizmi?" -> telefon+parol bilan tiklash.
class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});
  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _current = '';
  String? _error;
  int _attempts = 0;

  void _onKey(String digit) {
    if (_current.length >= 4) return;
    setState(() {
      _current += digit;
      _error = null;
    });
    if (_current.length == 4) _verify();
  }

  void _onDelete() {
    if (_current.isEmpty) return;
    setState(() => _current = _current.substring(0, _current.length - 1));
  }

  Future<void> _verify() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final ok = await PinService.instance.verifyPin(_current);
    if (ok) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
            (r) => false);
      }
    } else {
      _attempts++;
      if (_attempts >= 5) {
        if (!mounted) return;
        final auth = context.read<AuthProvider>();
        await auth.logout();
        await PinService.instance.clearPin();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
              (r) => false);
        }
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = 'Noto\'g\'ri PIN. Qolgan urinishlar: ${5 - _attempts}';
        _current = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PinPad(
          title: 'PIN kodni kiriting',
          subtitle: 'Davom etish uchun 4 raqamli kodni kiriting',
          filledCount: _current.length,
          error: _error,
          onKey: _onKey,
          onDelete: _onDelete,
          // PIN unutilganda telefon+parol bilan tiklash
          footer: TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PinResetScreen())),
            child: const Text(
              'PIN kodni unutdingizmi?',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}