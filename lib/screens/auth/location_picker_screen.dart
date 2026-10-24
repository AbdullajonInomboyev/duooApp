import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';

/// Sputnik tayllari (Esri World Imagery) + ustidan ko'cha/joy nomlari.
/// Ro'yxatdan o'tishdagi kichik xarita ham shularni ishlatadi.
const satelliteTileUrl =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
const satelliteLabelsUrl =
    'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';
const mapUserAgent = 'uz.duoo.app';

/// Sputnik xaritada do'kon joyini belgilash.
/// Markazdagi belgi = tanlangan joy. Xarita surilib, belgi do'kon ustiga
/// keltiriladi. Koordinata bo'lmasa — avval GPS bilan joriy joyga uchadi.
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
  bool _locating = false;

  // Toshkent markazi (boshlang'ich, agar koordinata bo'lmasa)
  static const _defaultCenter = LatLng(41.311081, 69.240562);

  bool get _hasInitial => widget.initialLat != null && widget.initialLng != null;

  @override
  void initState() {
    super.initState();
    _center = _hasInitial
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _defaultCenter;
    // Birinchi ochilishda do'kon egasi odatda do'konda turadi —
    // xaritani darhol uning joyiga olib boramiz
    if (!_hasInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToMyLocation());
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _snack('GPS o\'chirilgan. Xaritani qo\'lda suring yoki GPS ni yoqing.');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('Joylashuvga ruxsat yo\'q. Xaritani qo\'lda suring.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final loc = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      _center = loc;
      _mapController.move(loc, 18);
    } catch (_) {
      _snack('Joylashuvni aniqlab bo\'lmadi');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
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
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      // Xarita status bar ostigacha to'liq ekranda
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const SizedBox.shrink(),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _RoundButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.maybePop(context),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _hasInitial ? 18 : 13,
              maxZoom: 19,
              // Aylantirish o'chirilgan — belgi doim tik turadi
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onPositionChanged: (pos, _) {
                if (pos.center != null) _center = pos.center!;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: satelliteTileUrl,
                userAgentPackageName: mapUserAgent,
                maxNativeZoom: 19,
                maxZoom: 19,
              ),
              TileLayer(
                urlTemplate: satelliteLabelsUrl,
                userAgentPackageName: mapUserAgent,
                maxNativeZoom: 19,
                maxZoom: 19,
              ),
            ],
          ),
          // Markazdagi belgi: uchi aynan markazga tushadi
          const IgnorePointer(child: _CenterPin()),
          // Yo'riqnoma
          Positioned(
            top: topInset + 64,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 12),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app_outlined,
                      color: AppColors.primary, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Xaritani suring va kattalashtiring — belgi do\'koningiz '
                      'tomi ustida tursin',
                      style: TextStyle(fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // "Mening joylashuvim"
          Positioned(
            right: 16,
            bottom: 16,
            child: _RoundButton(
              icon: Icons.my_location,
              size: 52,
              busy: _locating,
              onTap: _locating ? null : _goToMyLocation,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.check),
              label: const Text('Shu joyni tasdiqlash'),
            ),
          ),
        ),
      ),
    );
  }
}

/// Markaziy belgi + yerdagi soya (Yandex uslubida).
class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    // Ikonka balandligi 52: uchi markazda bo'lishi uchun yarmicha yuqoriga
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on,
              size: 52,
              color: AppColors.primary,
              shadows: [Shadow(color: Color(0x66000000), blurRadius: 8)]),
          Transform.translate(
            offset: const Offset(0, -6),
            child: Container(
              width: 14,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Xarita ustidagi oq dumaloq tugma.
class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool busy;
  const _RoundButton({
    required this.icon,
    this.onTap,
    this.size = 44,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: const Color(0x55000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(icon, color: AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}
