import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/connectivity_provider.dart';
import 'widgets/no_internet_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_choice_screen.dart';
import 'services/api_service.dart';

/// Ekranlarga context'siz o'tish uchun (masalan, sessiya tugaganda).
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Full screen — ilova tepa (status bar) va past (navigatsiya) panellari
  // ostiga to'liq yoyiladi (edge-to-edge).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Panellar shaffof, ikonkalar qora (oq fonda ko'rinsin).
  // Ilova foni panellar ostida ham davom etadi (Mutolaa kabi).
  SystemChrome.setSystemUIOverlayStyle(AppTheme.lightOverlay);
  // Sessiya tugasa (token yangilanmasa) -> "Hisobingiz bormi?" oynasi
  ApiService.instance.onSessionExpired = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      (r) => false,
    );
  };
  runApp(const DuooApp());
}

class DuooApp extends StatelessWidget {
  const DuooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'DUOO',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        // Internet uzilsa barcha ekranlar tepasida banner chiqadi.
        // Internet bor paytda child o'zgarishsiz qaytadi — aks holda bo'sh
        // SafeArea status bar balandligini egallab, AppBar ustida ortiqcha
        // tasma paydo bo'ladi.
        builder: (context, child) {
          final page = child ?? const SizedBox.shrink();
          return Consumer<ConnectivityProvider>(
            builder: (context, conn, _) {
              if (conn.online) return page;
              return ColoredBox(
                color: AppColors.background,
                child: Column(
                  children: [
                    const SafeArea(bottom: false, child: NoInternetBanner()),
                    // Banner status bar'ni egalladi — ekran uni qayta
                    // qo'shmasin
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: page,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}