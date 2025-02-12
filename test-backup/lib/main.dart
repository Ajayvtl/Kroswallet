import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/generate_passkey.dart';
import 'screens/set_pin.dart';
import 'screens/verify_passkey.dart';
import 'screens/enter_pin.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(CryptoWalletApp());
}

class CryptoWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Wallet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/generate-passkey': (context) => GeneratePasskeyScreen(),
        '/verify-passkey': (context) => VerifyPasskeyScreen(),
        '/set-pin': (context) => SetPinScreen(),
        '/enter-pin': (context) => EnterPinScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
