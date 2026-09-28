import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/app_dialogs.dart';
import '../../services/api_service.dart';

/// Fikr va taklif yuborish ekrani.
/// Do'kon egasi fikr yozadi -> serverga boradi -> admin panelda o'qiydi.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty) {
      AppDialogs.info(context, 'Iltimos, fikringizni yozing.');
      return;
    }
    setState(() => _sending = true);
    try {
      await ApiService.instance.dio
          .post('/core/feedback/', data: {'message': msg});
      if (!mounted) return;
      setState(() => _sending = false);
      _ctrl.clear();
      await AppDialogs.success(context, 'Fikringiz uchun rahmat! Yuborildi.');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppDialogs.error(context, 'Yuborishda xatolik. Qaytadan urining.');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fikr va takliflar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ilovani yaxshilash uchun fikringiz muhim. Qaysi mahsulot '
              'kerakligini yoki takliflaringizni yozing:',
              style: TextStyle(color: AppColors.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _ctrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Fikringizni shu yerga yozing...',
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.onPrimary))
                  : const Icon(Icons.send),
              label: Text(_sending ? 'Yuborilmoqda...' : 'Yuborish'),
            ),
          ],
        ),
      ),
    );
  }
}