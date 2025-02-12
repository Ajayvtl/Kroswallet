import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class StorageHelper {
  static final _storage = FlutterSecureStorage();

  // Save a value to storage
  static Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<void> debugStoredPrivateKey() async {
    final rawPrivateKey = await _storage.read(key: 'private_key');
    if (rawPrivateKey != null) {
      print('Raw Stored Private Key: $rawPrivateKey');
    } else {
      print('No private key found in storage.');
    }
  }

  static Future<void> debugSecureStorage() async {
    final allData = await _storage.readAll();
    print('All Stored Data: $allData');
  }

  static Future<void> debugStoredWallet() async {
    final walletAddress = await _storage.read(key: 'wallet_address');
    final privateKey = await _storage.read(key: 'private_key');
    print('Stored Wallet Address: $walletAddress');
    print('Stored Private Key (Raw): $privateKey');
  }

  // Retrieve a value from storage
  static Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  // Delete a specific key
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Save passkey securely
  static Future<void> savePasskey(String passkey) async {
    await _storage.write(key: 'passkey', value: passkey);
  }

  // Retrieve passkey
  static Future<String?> getPasskey() async {
    return await _storage.read(key: 'passkey');
  }

// Save PIN securely
  static Future<void> savePin(String pin) async {
    await _storage.write(key: 'pin', value: pin);
  }

// Retrieve PIN
  static Future<String?> getPin() async {
    return await _storage.read(key: 'pin');
  }

  static Future<void> clearData() async {
    await _storage.deleteAll();
  }

  // Clear all data from storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> saveSelectedNetwork(Map<String, String> network) async {
    await _storage.write(key: 'selected_network', value: jsonEncode(network));
  }

  static Future<Map<String, String>?> getSelectedNetwork() async {
    final networkData = await _storage.read(key: 'selected_network');
    if (networkData != null) {
      return Map<String, String>.from(jsonDecode(networkData));
    }
    return null;
  }

  static Future<void> saveTransactions(
      String networkName, List<Map<String, dynamic>> transactions) async {
    final key = 'transactions_$networkName';
    await _storage.write(key: key, value: jsonEncode(transactions));
  }

  static Future<List<Map<String, dynamic>>> getTransactions(
      String networkName) async {
    final key = 'transactions_$networkName';
    final transactionsData = await _storage.read(key: key);
    if (transactionsData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(transactionsData));
    }
    return [];
  }
}
