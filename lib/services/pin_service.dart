import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PIN kodni xavfsiz saqlash va tekshirish.
/// PIN telefonда (secure storage) saqlanadi, serverga bormaydi.
class PinService {
  static final PinService instance = PinService._();
  PinService._();

  final _storage = const FlutterSecureStorage();
  static const _key = 'user_pin';

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _key);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _key, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final saved = await _storage.read(key: _key);
    return saved != null && saved == pin;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _key);
  }
}