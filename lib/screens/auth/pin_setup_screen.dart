import 'package:flutter/material.dart';
import '../../services/pin_service.dart';
import '../home/main_shell.dart';
import 'pin_widgets.dart';

/// PIN o'rnatish — ro'yxatdan o'tgandan keyin.
/// Ikki marta kiritadi (tasdiqlash), keyin ichkariga kiradi.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});
  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _first = '';
  String _current = '';
  bool _confirming = false;
  String? _error;

  void _onKey(String digit) {
    if (_current.length >= 4) return;
    setState(() {
      _current += digit;
      _error = null;
    });
    if (_current.length == 4) _handleComplete();
  }

  void _onDelete() {
    if (_current.isEmpty) return;
    setState(() => _current = _current.substring(0, _current.length - 1));
  }

  Future<void> _handleComplete() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!_confirming) {
      // Birinchi kiritish -> tasdiqlashga o'tamiz
      setState(() {
        _first = _current;
        _current = '';
        _confirming = true;
      });
    } else {
      // Tasdiqlash
      if (_current == _first) {
        await PinService.instance.setPin(_current);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainShell()),
              (r) => false);
        }
      } else {
        setState(() {
          _error = 'PIN kodlar mos kelmadi. Qaytadan urining.';
          _current = '';
          _first = '';
          _confirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PinPad(
          title: _confirming ? 'PIN kodni tasdiqlang' : 'PIN kod o\'rnating',
          subtitle: _confirming
              ? 'Xuddi shu 4 raqamni qayta kiriting'
              : 'Kirish uchun 4 raqamli kod o\'ylab toping',
          filledCount: _current.length,
          error: _error,
          onKey: _onKey,
          onDelete: _onDelete,
        ),
      ),
    );
  }
}