import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletManager {
  final _storage = FlutterSecureStorage();

  Future<void> saveWallet(
      String network, String walletAddress, String privateKey) async {
    final data = jsonEncode({
      'address': walletAddress,
      'privateKey': privateKey,
    });
    await _storage.write(key: '$network:$walletAddress', value: data);
  }

  Future<Map<String, dynamic>?> getWallet(
      String network, String walletAddress) async {
    final data = await _storage.read(key: '$network:$walletAddress');
    return data != null ? jsonDecode(data) : null;
  }

  Future<List<Map<String, dynamic>>> getAllWallets(String network) async {
    final allKeys = await _storage.readAll();
    final List<Map<String, dynamic>> wallets = allKeys.entries
        .where((entry) => entry.key.startsWith(network))
        .map((entry) {
      final walletData = jsonDecode(entry.value) as Map<String, dynamic>;
      return walletData;
    }).toList();
    return wallets;
  }
}
