import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';

/// OpenStreetMap xarita — lokatsiyani ko'rish/tanlash.
/// Oddiy va sputnik ko'rinishi. Markazdagi nuqta = tanlangan joy.
/// Kalit kerak emas (bepul).
class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _mapController = MapController();
  late LatLng _center;
  bool _satellite = false;
  bool _locating = false;

  // Toshkent markazi (boshlang'ich, agar koordinata bo'lmasa)
  static const _defaultCenter = LatLng(41.311081, 69.240562);

  @override
  void initState() {
    super.initState();
    _center = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _defaultCenter;
  }

  // Oddiy xarita va sputnik uchun tile manzillari (bepul)
  String get _tileUrl => _satellite
      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _snack('GPS o\'chirilgan');
        setState(() => _locating = false);
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('Joylashuvga ruxsat yo\'q');
        setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = loc;
        _locating = false;
      });
      _mapController.move(loc, 16);
    } catch (_) {
      setState(() => _locating = false);
      _snack('Joylashuvni aniqlab bo\'lmadi');
    }
  }

  void _snack(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(m)));
    }
  }

  void _confirm() {
    Navigator.pop(context, {
      'lat': _center.latitude,
      'lng': _center.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joylashuvni belgilang'),
        actions: [
          // Sputnik / oddiy almashtirish
          IconButton(
            icon: Icon(_satellite ? Icons.map : Icons.satellite_alt),
            tooltip: _satellite ? 'Oddiy xarita' : 'Sputnik',
            onPressed: () => setState(() => _satellite = !_satellite),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: (pos, _) {
                if (pos.center != null) _center = pos.center!;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'uz.godostavka.store',
                maxZoom: 19,
              ),
            ],
          ),
          // Markazdagi nuqta (pin) - xarita surilsa shu yer tanlanadi
          const IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on,
                  size: 50, color: AppColors.primary),
            ),
          ),
          // "Mening joylashuvim" tugmasi
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              heroTag: 'myloc',
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              onPressed: _locating ? null : _goToMyLocation,
              child: _locating
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Icon(Icons.my_location),
            ),
          ),
          // Yo'riqnoma
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 8),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Xaritani suring — belgi do\'kon ustida tursin',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check),
            label: const Text('Shu joyni tasdiqlash'),
          ),
        ),
      ),
    );
  }
}