import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  Future<void> _startSplashScreen() async {
    // Wait for 3 seconds to show the splash screen
    await Future.delayed(Duration(seconds: 3));
    _checkUserSetup();
  }

  Future<void> _checkUserSetup() async {
    String? passkey = await StorageHelper.getPasskey();
    String? pin = await StorageHelper.getPin();

    if (passkey == null) {
      Navigator.pushReplacementNamed(context, '/generate-passkey');
    } else if (pin == null) {
      Navigator.pushReplacementNamed(context, '/set-pin');
    } else {
      Navigator.pushReplacementNamed(context, '/enter-pin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/bg.png'), // Make sure the file exists
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Colors.amber[700] ?? Colors.amber),
          ),
        ),
      ),
    );
  }
}
