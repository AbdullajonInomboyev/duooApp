import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Internet holatini kuzatadi. Butun ilova shundan xabardor bo'ladi.
class ConnectivityProvider extends ChangeNotifier {
  final _connectivity = Connectivity();
  StreamSubscription? _sub;
  bool _online = true;

  bool get online => _online;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _update(result);
    _sub = _connectivity.onConnectivityChanged.listen(_update);
  }

  // Ham bitta qiymat, ham ro'yxat qaytishini qo'llab-quvvatlaydi
  void _update(dynamic result) {
    final bool has;
    if (result is List) {
      has = result.any((r) => r != ConnectivityResult.none);
    } else {
      has = result != ConnectivityResult.none;
    }
    if (has != _online) {
      _online = has;
      notifyListeners();
    }
  }

  Future<bool> recheck() async {
    final result = await _connectivity.checkConnectivity();
    _update(result);
    return _online;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}