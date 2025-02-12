import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HeroSection extends StatelessWidget {
  final String walletAddress;
  final BigInt balance;
  final String tokenSymbol;
  final String networkName;
  final Function onCopyAddress;
  final Function onSend;
  final Function onReceive;
  final Function onSwitchNetwork;

  HeroSection({
    required this.walletAddress,
    required this.balance,
    required this.tokenSymbol,
    required this.networkName,
    required this.onCopyAddress,
    required this.onSend,
    required this.onReceive,
    required this.onSwitchNetwork,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Network Name and More Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => onSwitchNetwork(),
                icon: Icon(Icons.swap_horiz, color: Colors.white),
                label: Text(
                  networkName,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Additional Options'),
                      content: Text('No options available at the moment.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),

          // Wallet Address
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                walletAddress.length > 8
                    ? '${walletAddress.substring(0, 4)}...${walletAddress.substring(walletAddress.length - 4)}'
                    : walletAddress,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  Clipboard.setData(ClipboardData(text: walletAddress));
                  Fluttertoast.showToast(
                    msg: "Address copied to clipboard!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  print("Wallet Address: $walletAddress");
                  onCopyAddress();
                },
                child: Icon(Icons.copy, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Balance
          Text(
            '${(balance / BigInt.from(10).pow(18)).toStringAsFixed(6)} $tokenSymbol',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your Wallet Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 30),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Receive Button
              ElevatedButton.icon(
                onPressed: () => onReceive(),
                icon: Icon(Icons.download, color: Colors.white),
                label: Text('Receive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Send Button
              ElevatedButton.icon(
                onPressed: () => onSend(),
                icon: Icon(Icons.upload, color: Colors.white),
                label: Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
