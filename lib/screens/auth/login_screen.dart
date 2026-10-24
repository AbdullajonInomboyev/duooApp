import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/app_dialogs.dart';
import '../../providers/auth_provider.dart';
import '../../services/pin_service.dart';
import 'pin_setup_screen.dart';
import 'register_screen.dart';

/// Kirish — hisobi bor do'kon egasi uchun (telefon + parol).
/// Muvaffaqiyatli -> shu telefon uchun yangi PIN o'rnatiladi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController(text: '+998');
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  Future<void> _submit() async {
    final phone = _phone.text.trim();
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!phone.startsWith('+998') || digits.length != 12) {
      AppDialogs.error(context,
          'Telefon raqam noto\'g\'ri. Format: +998 XX XXX XX XX (12 ta raqam).');
      return;
    }
    if (_password.text.isEmpty) {
      AppDialogs.error(context, 'Parolni kiriting.');
      return;
    }
    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(phone, _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      // Eski PIN (boshqa hisobniki bo'lishi mumkin) o'chiriladi
      await PinService.instance.clearPin();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PinSetupScreen()),
          (r) => false);
    } else {
      AppDialogs.error(context, auth.error ?? 'Kirishda xatolik');
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirish')),
      body: SingleChildScrollView(
        padding: AppSpacing.scroll(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ro'yxatdan o'tishda kiritgan telefon raqam va parolingizni "
              'kiriting.',
              style: TextStyle(color: AppColors.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Telefon raqam',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(hintText: '+998 90 123 45 67'),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Parol', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _busy ? null : _submit(),
              decoration: InputDecoration(
                hintText: 'Parolingiz',
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.onPrimary))
                  : const Text('Kirish'),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text(
                  "Hisobingiz yo'qmi? Ro'yxatdan o'ting",
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
