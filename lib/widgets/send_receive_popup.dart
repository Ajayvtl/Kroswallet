import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';

class SendReceivePopup extends StatefulWidget {
  final String title;
  final String walletAddress;
  final BigInt balance;
  final String networkName;
  final Function(String address, BigInt amount) onSubmit;

  SendReceivePopup({
    required this.title,
    required this.walletAddress,
    required this.balance,
    required this.networkName,
    required this.onSubmit,
  });

  @override
  _SendReceivePopupState createState() => _SendReceivePopupState();
}

class _SendReceivePopupState extends State<SendReceivePopup> {
  TextEditingController _addressController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  BigInt _gasFee = BigInt.zero;
  String? _errorMessage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.title == 'Send') {
      _fetchGasFee();
    }
  }

  Future<void> _fetchGasFee() async {
    try {
      // Replace with dynamic gas fee fetching logic
      BigInt gasPrice = BigInt.from(20000000000); // 20 Gwei
      BigInt gasLimit = BigInt.from(21000); // Typical transfer gas limit
      setState(() {
        _gasFee = gasPrice * gasLimit;
      });
    } catch (e) {
      print('Error fetching gas fee: $e');
    }
  }

  bool _isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _onSend() {
    final address = _addressController.text.trim();
    final amount =
        BigInt.tryParse(_amountController.text.trim()) ?? BigInt.zero;

    if (!_isValidAddress(address)) {
      setState(() {
        _errorMessage = 'Invalid wallet address.';
      });
      return;
    }

    if (amount <= BigInt.zero) {
      setState(() {
        _errorMessage = 'Amount must be greater than zero.';
      });
      return;
    }

    final totalCost = amount + _gasFee;
    if (totalCost > widget.balance) {
      setState(() {
        _errorMessage = 'Insufficient balance. Please top up your wallet.';
      });
      return;
    }

    setState(() {
      _isSending = true;
    });

    // Call onSubmit callback
    widget.onSubmit(address, amount);

    Fluttertoast.showToast(msg: 'Transaction sent to $address');
    Navigator.pop(context);
  }

  void _scanQrCode() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan QR Code'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            onDetect: (barcodeCapture) {
              final barcodes = barcodeCapture.barcodes;
              if (barcodes.isNotEmpty) {
                final rawValue = barcodes.first.rawValue ?? '';
                final scannedAddress = _parseAddress(rawValue);
                Navigator.pop(context); // Close the scanner dialog
                if (_isValidAddress(scannedAddress)) {
                  _addressController.text = scannedAddress;
                  Fluttertoast.showToast(msg: 'Address scanned successfully!');
                } else {
                  Fluttertoast.showToast(msg: 'Invalid address in QR code.');
                }
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

// Helper function to parse address
  String _parseAddress(String data) {
    // MetaMask and similar wallets may prepend 'ethereum:' to the address
    if (data.startsWith('ethereum:')) {
      return data.replaceFirst('ethereum:', '').split('?').first;
    }
    return data; // Return as-is if no prefix is found
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: widget.title == 'Receive'
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scan this QR code to receive funds:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200, // Explicit width
                    height: 200, // Explicit height
                    child: QrImageView(
                      data: widget.walletAddress,
                      version: QrVersions.auto,
                      gapless: false,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  SelectableText(
                    widget.walletAddress,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.walletAddress));
                      Fluttertoast.showToast(msg: 'Wallet address copied!');
                    },
                    child: Text('Copy Address'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Recipient Address',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code_scanner),
                        onPressed: _scanQrCode,
                      ),
                      errorText: _errorMessage,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount to Send',
                      suffixIcon: TextButton(
                        child: Text('Max'),
                        onPressed: () {
                          final maxAmount = widget.balance - _gasFee;
                          if (maxAmount > BigInt.zero) {
                            _amountController.text = maxAmount.toString();
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Insufficient balance.');
                          }
                        },
                      ),
                    ),
                  ),
                  if (_gasFee > BigInt.zero)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Estimated Gas Fee: ${_gasFee / BigInt.from(10).pow(18)} BNB',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
      ),
      actions: widget.title == 'Receive'
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isSending ? null : _onSend,
                child: Text('Send'),
              ),
            ],
    );
  }
}
