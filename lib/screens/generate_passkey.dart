import 'package:flutter/material.dart';
import 'dart:math';
import 'package:bip39/bip39.dart' as bip39;
import '../utils/storage_helper.dart';
import '../services/api_service.dart';
import '../services/wallet_manager.dart';

class GeneratePasskeyScreen extends StatelessWidget {
  final List<String> _words = [
    "Apple",
    "Tiger",
    "Car",
    "House",
    "Banana",
    "Dog",
    "Sun",
    "Laptop",
    "Tree",
    "Book",
    "Star",
    "Moon"
  ];

  String _generatePasskey() {
    return bip39.generateMnemonic();
  }

  Future<void> _savePasskeyAndWalletToServer(String passkey) async {
    try {
      await ApiService.savePasskey(passkey);
      await StorageHelper.savePasskey(passkey);

      String? walletAddress = await WalletHelper.createOrFetchWallet();
      if (walletAddress != null) {
        await ApiService.saveWalletAddress(walletAddress);
      }

      print(
          "Passkey and Wallet Address successfully saved to server and locally.");
    } catch (e) {
      print("Error saving passkey and wallet: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String passkey = _generatePasskey();

    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Passkey'),
        backgroundColor: Colors.amber[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Passkey:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: passkey.split(' ').length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}. ${passkey.split(' ')[index]}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () async {
                  await StorageHelper.savePasskey(passkey);
                  Navigator.pushReplacementNamed(context, '/verify-passkey');
                },
                child: Text(
                  'Proceed',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
