import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:beacon/providers/location_provider.dart';
import 'package:beacon/providers/p2p_provider.dart';
import 'package:beacon/providers/auth_provider.dart';
import 'package:beacon/screens/splash_screen.dart';
import 'package:beacon/screens/home_screen.dart';
import 'package:beacon/screens/auth_screen.dart';
import 'package:beacon/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => P2PProvider()),
      ],
      child: MaterialApp(
        title: 'Beacon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Consumer<AuthProvider>(
          builder: (ctx, authProvider, _) {
            if (authProvider.isInitializing) {
              return const SplashScreen();
            }
            return authProvider.isAuthenticated 
                ? const HomeScreen() 
                : const AuthScreen();
          },
        ),
      ),
    );
  }
}