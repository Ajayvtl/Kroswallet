import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final String networkExplorerBaseUrl;

  TransactionList(
      {required this.transactions, required this.networkExplorerBaseUrl});

  // Open transaction explorer
  void _openExplorer(String hash) async {
    final url = '$networkExplorerBaseUrl/tx/$hash';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: 'Could not open transaction explorer.');
    }
  }

  // Shorten wallet address
  String shortenAddress(String address) {
    if (address.length <= 4) return address;
    return '${address.substring(0, 2)}...${address.substring(address.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No transactions found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];

        // Extract and sanitize data
        final toAddress = tx['to'] ?? 'Unknown';
        final fromAddress = tx['from'] ?? 'Unknown';
        final valueWei =
            BigInt.tryParse(tx['value']?.toString() ?? '0') ?? BigInt.zero;
        final valueBNB = valueWei / BigInt.from(10).pow(18);
        final hash = tx['hash'] ?? 'Unknown';
        final timestamp = tx['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] * 1000)
                .toLocal()
            : null;
        final isSent = tx['from'] != null &&
            tx['from'] == 'YourWalletAddress'; // Replace with actual logic

        // Format date and time
        final date = timestamp != null
            ? DateFormat('MMM d, yyyy').format(timestamp)
            : 'Unknown Date';
        final time = timestamp != null
            ? DateFormat('h:mm a').format(timestamp)
            : 'Unknown Time';

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.grey[900],
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 8),

                // Transaction Details
                Row(
                  children: [
                    // Icon
                    Container(
                      decoration: BoxDecoration(
                        color: isSent ? Colors.red[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        isSent ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isSent ? Colors.red : Colors.green,
                      ),
                    ),
                    SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${isSent ? 'Send' : 'Receive'} BNB',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'To: ${shortenAddress(toAddress)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            'From: ${shortenAddress(fromAddress)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isSent ? '-' : '+'}${valueBNB.toStringAsFixed(6)} BNB',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Timestamp and Explorer Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: Colors.blue),
                      onPressed: () {
                        if (hash != 'Unknown') {
                          _openExplorer(hash);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
