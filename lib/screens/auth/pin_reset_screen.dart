import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/app_dialogs.dart';
import '../../providers/auth_provider.dart';
import '../../services/pin_service.dart';
import 'pin_setup_screen.dart';

/// PIN tiklash — telefon + parol bilan.
/// PIN unutilganda: telefon raqam + parol kiritiladi, to'g'ri bo'lsa
/// yangi PIN o'rnatishga o'tadi (SMS kerak emas).
class PinResetScreen extends StatefulWidget {
  const PinResetScreen({super.key});
  @override
  State<PinResetScreen> createState() => _PinResetScreenState();
}

class _PinResetScreenState extends State<PinResetScreen> {
  final _phone = TextEditingController(text: '+998');
  final _password = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    final phone = _phone.text.trim();
    final pass = _password.text;
    if (phone.length < 7 || pass.isEmpty) {
      AppDialogs.info(context, 'Telefon va parolni to\'liq kiriting.');
      return;
    }
    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(phone, pass);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      // To'g'ri — eski PINni o'chirib, yangi PIN o'rnatishga o'tamiz
      await PinService.instance.clearPin();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PinSetupScreen()),
          (r) => false);
    } else {
      AppDialogs.error(context, 'Telefon yoki parol xato. Qaytadan urining.');
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
      appBar: AppBar(title: const Text('PIN kodni tiklash')),
      body: SingleChildScrollView(
        padding: AppSpacing.scroll(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'PIN kodni tiklash uchun ro\'yxatdan o\'tishdagi telefon raqam '
              'va parolingizni kiriting. Tasdiqlangach yangi PIN o\'rnatasiz.',
              style: TextStyle(color: AppColors.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Telefon raqam',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '+998 90 123 45 67'),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Parol', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Parolingiz'),
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
                  : const Text('Tasdiqlash'),
            ),
          ],
        ),
      ),
    );
  }
}