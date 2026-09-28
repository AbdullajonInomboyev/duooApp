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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Full screen — ilova tepa (status bar) va past (navigatsiya) panellari
  // ostiga to'liq yoyiladi (edge-to-edge).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Panellar shaffof, ikonkalar qora (oq fonda ko'rinsin)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
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
        title: 'DUOO',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        // Butun ilovada internet uzilsa tepada banner chiqadi
        builder: (context, child) {
          return Column(
            children: [
              Consumer<ConnectivityProvider>(
                builder: (_, conn, __) => SafeArea(
                  bottom: false,
                  child: conn.online
                      ? const SizedBox.shrink()
                      : const NoInternetBanner(),
                ),
              ),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}