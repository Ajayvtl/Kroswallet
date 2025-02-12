import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/bnb_provider.dart';

class ImportExportWallet extends StatelessWidget {
  String _rpcUrl = 'https://bsc-dataseed.binance.org/';
  final bscScanApiKey = 'FVM2ND5T8WTDQQCBF71XUNB3U3QMU6ZBE3';
  late final BnbProvider _bnbProvider = BnbProvider(_rpcUrl, bscScanApiKey);
  // final BnbProvider _bnbProvider = BnbProvider();

  // Popup for exporting the private key
  void _showExportPopup(BuildContext context) async {
    final privateKey = await _bnbProvider.exportWallet();
    if (privateKey != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Export Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Private Key: $privateKey'),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: privateKey));
                  print('Private Key: $privateKey');
                  Fluttertoast.showToast(
                      msg: 'Private key copied to clipboard!');
                },
                child: Text('Copy to Clipboard'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } else {
      Fluttertoast.showToast(msg: 'No wallet found to export.');
    }
  }

  // Popup for importing a wallet
  void _showImportPopup(BuildContext context) {
    final TextEditingController privateKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Wallet'),
        content: TextField(
          controller: privateKeyController,
          decoration: InputDecoration(labelText: 'Enter Private Key'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final privateKey = privateKeyController.text.trim();
              if (privateKey.isNotEmpty) {
                await _bnbProvider.importWallet(privateKey);
                Navigator.pop(context);
                Fluttertoast.showToast(msg: 'Wallet Imported!');
              } else {
                Fluttertoast.showToast(msg: 'Private key is empty!');
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showExportPopup(context),
            icon: Icon(Icons.upload),
            label: Text('Export Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showImportPopup(context),
            icon: Icon(Icons.download),
            label: Text('Import Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
