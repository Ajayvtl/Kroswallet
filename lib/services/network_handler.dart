import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHandler {
  final String rpcUrl;
  final String chainId;

  NetworkHandler({required this.rpcUrl, required this.chainId});

  Future<List<dynamic>> fetchTransactions(String walletAddress) async {
    final url =
        "$rpcUrl/api?module=account&action=txlist&address=$walletAddress&chainId=$chainId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'];
      } else {
        throw Exception("Failed to fetch transactions");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getTokenBalance(
      String walletAddress, String tokenAddress) async {
    final url =
        "$rpcUrl/api?module=account&action=tokenbalance&address=$walletAddress&contractaddress=$tokenAddress&chainId=$chainId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'];
      } else {
        throw Exception("Failed to fetch token balance");
      }
    } catch (e) {
      rethrow;
    }
  }
}
