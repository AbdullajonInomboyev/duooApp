import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/uzbekistan_regions.dart';
import '../../providers/auth_provider.dart';
import 'pin_setup_screen.dart';
import 'location_picker_screen.dart';
import 'login_screen.dart';
import '../../core/app_dialogs.dart';

/// Ro'yxatdan o'tish — telefon, ism, do'kon nomi + rasmi, viloyat/tuman,
/// sputnik xaritada belgilangan lokatsiya. Muvaffaqiyatli -> PIN o'rnatish.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phone = TextEditingController(text: '+998');
  final _fullName = TextEditingController();
  final _shopName = TextEditingController();
  final _password = TextEditingController();
  final _address = TextEditingController();

  String? _region;
  String? _district;
  bool _submitting = false;

  // Do'kon rasmi (XFile - web va mobilda ishlaydi)
  XFile? _shopImage;
  final _picker = ImagePicker();

  // Lokatsiya
  double? _lat;
  double? _lng;

  List<String> get _districts =>
      _region != null ? (uzRegions[_region] ?? const []) : const [];

  // ---------- Do'kon rasmi ----------
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galereyadan tanlash'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kamera bilan suratga olish'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
          source: source, maxWidth: 1200, imageQuality: 80);
      if (picked != null) {
        setState(() => _shopImage = picked);
      }
    } catch (_) {
      _snack('Rasm tanlashda xatolik');
    }
  }

  // ---------- Lokatsiya (sputnik xarita) ----------
  Future<void> _pickOnMap() async {
    final res = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLat: _lat, initialLng: _lng),
      ),
    );
    if (res == null || !mounted) return;
    setState(() {
      // 6 xonaga yaxlitlaymiz (server decimal_places=6 kutadi)
      _lat = double.parse(res['lat']!.toStringAsFixed(6));
      _lng = double.parse(res['lng']!.toStringAsFixed(6));
    });
  }

  void _snack(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(m)));
    }
  }

  Future<void> _submit() async {
    // Maydonlarni oldindan tekshiramiz — serverga bormay, darrov aniq aytamiz
    final phone = _phone.text.trim();
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!phone.startsWith('+998') || digits.length != 12) {
      AppDialogs.error(context,
          'Telefon raqam noto\'g\'ri. Format: +998 XX XXX XX XX (12 ta raqam).');
      return;
    }
    if (_fullName.text.trim().isEmpty) {
      AppDialogs.error(context, 'Ism va familiyani kiriting.');
      return;
    }
    if (_shopName.text.trim().isEmpty) {
      AppDialogs.error(context, 'Do\'kon nomini kiriting.');
      return;
    }
    if (_password.text.length < 4) {
      AppDialogs.error(context, 'Parol kamida 4 ta belgidan iborat bo\'lsin.');
      return;
    }
    if (_region == null || _district == null) {
      AppDialogs.error(context, 'Viloyat va tumanni tanlang.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.register(
        data: {
          'phone': _phone.text.trim(),
          'full_name': _fullName.text.trim(),
          'shop_name': _shopName.text.trim(),
          'password': _password.text,
          'region_name': _region,
          'district_name': _district,
          'address_text': _address.text.trim(),
          if (_lat != null) 'latitude': _lat,
          if (_lng != null) 'longitude': _lng,
        },
        image: _shopImage,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (ok) {
        // Ro'yxatdan o'tdi -> PIN o'rnatishga
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PinSetupScreen()),
            (route) => false);
      } else {
        AppDialogs.error(
            context, auth.error ?? 'Ro\'yxatdan o\'tishda xatolik');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppDialogs.error(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ro'yxatdan o'tish")),
      body: SingleChildScrollView(
        padding: AppSpacing.scroll(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Do'koningiz ma'lumotlarini kiriting",
                style: TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.md),
            _label('Telefon raqam'),
            TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(hintText: '+998 90 123 45 67')),
            _label('Ism va familiya'),
            TextField(
                controller: _fullName,
                decoration:
                    const InputDecoration(hintText: 'Ismingizni kiriting')),
            _label("Do'kon nomi"),
            TextField(
                controller: _shopName,
                decoration: const InputDecoration(
                    hintText: "Do'koningiz nomini kiriting")),
            _label('Parol'),
            TextField(
                controller: _password,
                obscureText: true,
                decoration:
                    const InputDecoration(hintText: 'Parol o\'ylab toping')),
            _label("Do'kon rasmi"),
            // Rasm yuklash bloki
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: _shopImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            kIsWeb
                                ? Image.network(_shopImage!.path,
                                    fit: BoxFit.cover)
                                : Image.file(File(_shopImage!.path),
                                    fit: BoxFit.cover),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: AppColors.primary, size: 32),
                          SizedBox(height: 8),
                          Text('Rasm yuklash',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      ),
              ),
            ),
            _label('Viloyat'),
            DropdownButtonFormField<String>(
              value: _region,
              isExpanded: true,
              hint: const Text('Viloyatni tanlang'),
              items: uzRegions.keys
                  .map((r) =>
                      DropdownMenuItem<String>(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() {
                _region = v;
                _district = null;
              }),
            ),
            _label('Tuman'),
            DropdownButtonFormField<String>(
              value: _district,
              isExpanded: true,
              hint: Text(_region == null
                  ? 'Avval viloyatni tanlang'
                  : 'Tumanni tanlang'),
              items: _districts
                  .map((d) =>
                      DropdownMenuItem<String>(value: d, child: Text(d)))
                  .toList(),
              onChanged: _region == null
                  ? null
                  : (v) => setState(() => _district = v),
            ),
            _label("Manzil (ko'cha, uy)"),
            TextField(
                controller: _address,
                decoration: const InputDecoration(
                    hintText: 'Masalan: Chilonzor 5-kvartal, 12-uy')),
            _label('Aniq lokatsiya'),
            _buildLocationBlock(),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.onPrimary))
                  : const Text("Ro'yxatdan o'tish"),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text(
                  'Hisobingiz bormi? Kirish',
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

  /// Lokatsiya bloki: belgilangan bo'lsa kichik sputnik xarita + belgi,
  /// bo'lmasa "Xaritadan belgilash" tugmasi.
  Widget _buildLocationBlock() {
    final hasLoc = _lat != null && _lng != null;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasLoc)
            SizedBox(
              height: 150,
              child: IgnorePointer(
                child: FlutterMap(
                  // Koordinata o'zgarsa xarita qayta quriladi
                  key: ValueKey('$_lat,$_lng'),
                  options: MapOptions(
                    initialCenter: LatLng(_lat!, _lng!),
                    initialZoom: 17,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: satelliteTileUrl,
                      userAgentPackageName: mapUserAgent,
                      maxNativeZoom: 19,
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: LatLng(_lat!, _lng!),
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: const Icon(Icons.location_on,
                            size: 44,
                            color: AppColors.primary,
                            shadows: [
                              Shadow(color: Color(0x66000000), blurRadius: 6)
                            ]),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      hasLoc ? Icons.check_circle : Icons.location_off_outlined,
                      color: hasLoc ? AppColors.success : AppColors.outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hasLoc
                            ? "Do'kon joyi xaritada belgilandi"
                            : "Do'kon joyi hali belgilanmagan",
                        style: TextStyle(
                            color: hasLoc
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickOnMap,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(hasLoc
                      ? "Joyni o'zgartirish"
                      : 'Xaritadan belgilash'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
}