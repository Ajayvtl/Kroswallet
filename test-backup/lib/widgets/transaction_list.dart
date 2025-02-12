import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  TransactionList({required this.transactions});

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
        final valueWei =
            BigInt.tryParse(tx['value']?.toString() ?? '0') ?? BigInt.zero;
        final valueBNB =
            valueWei / BigInt.from(10).pow(18); // Convert Wei to BNB
        final valueUSD = (valueBNB.toDouble() * 690.0)
            .toStringAsFixed(2); // Example conversion rate
        final hash = tx['hash'] ?? 'Unknown';
        final timestamp = tx['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] * 1000)
                .toLocal()
            : DateTime.now();
        final isSent = tx['from'] != null &&
            tx['from'] == 'YourWalletAddress'; // Replace with actual logic
        final status = tx['status'] ?? 'Confirmed'; // Default status

        // Format date and time
        final date = DateFormat('MMM d, yyyy').format(timestamp);
        final time = DateFormat('h:mm a').format(timestamp);

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
                            isSent ? 'Send' : 'Receive',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[400],
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
                        SizedBox(height: 4),
                        Text(
                          '${isSent ? '-' : '+'}\$$valueUSD USD',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Timestamp
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
