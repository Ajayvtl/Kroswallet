import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://yourserver.com/api";

  // Save Passkey & Wallet Address to Server
  static Future<void> savePasskey(String passkey) async {
    final url = Uri.parse("$baseUrl/save-passkey");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"passkey": passkey}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save passkey");
    }
  }

  static Future<void> saveWalletAddress(String walletAddress) async {
    final url = Uri.parse("$baseUrl/save-wallet");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"walletAddress": walletAddress}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save wallet address");
    }
  }

  // Restore Wallet from Server
  static Future<List<String>> restoreWallet(String passkey) async {
    final url = Uri.parse("$baseUrl/restore-wallet");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"passkey": passkey}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data["wallets"]);
    } else {
      throw Exception("Failed to restore wallet");
    }
  }

  // Fetch Live Rates (USDT, BNB, etc.)
  static Future<double> getLiveRate(String currency) async {
    final url = Uri.parse("$baseUrl/live-rates?currency=$currency");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["rate"];
    } else {
      throw Exception("Failed to fetch live rate");
    }
  }

  // Fetch Transaction History
  static Future<List<Map<String, dynamic>>> getTransactions(
      String walletAddress) async {
    final url = Uri.parse("$baseUrl/transactions?wallet=$walletAddress");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["transactions"]);
    } else {
      throw Exception("Failed to fetch transactions");
    }
  }

  // Buy USDT via Payment Gateway
  static Future<void> buyUSDT(double amount, String paymentMethod) async {
    final url = Uri.parse("$baseUrl/buy-usdt");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "paymentMethod": paymentMethod,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to buy USDT");
    }
  }
}
