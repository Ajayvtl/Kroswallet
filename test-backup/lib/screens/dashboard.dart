import 'package:flutter/material.dart';
import '../widgets/hero_section.dart';
import '../widgets/transaction_list.dart';
import '../widgets/add_network_popup.dart';
import '../widgets/switch_network_popup.dart';
import '../widgets/import_export_wallet.dart';
import '../widgets/send_receive_popup.dart';
import '../utils/bnb_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../utils/storage_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart'; // Required for Clipboard and ClipboardData

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _refreshTimer;
  String _rpcUrl = 'https://bsc-dataseed.binance.org/';
  final bscScanApiKey = 'FVM2ND5T8WTDQQCBF71XUNB3U3QMU6ZBE3';
  late final BnbProvider _bnbProvider = BnbProvider(_rpcUrl, bscScanApiKey);
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _walletAddress = '';
  String _networkName = 'BNB Network';
  String _selectedToken = 'BNB';
  BigInt _balance = BigInt.zero;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _initializeWallet();
    _logStoredPrivateKey();
    StorageHelper.debugStoredWallet(); // Set up auto-refresh every 3 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 12), (timer) async {
      try {
        await _loadBalance();
        if (_balance > BigInt.zero) {
          await _fetchTransactions();
        }
      } catch (e) {
        print('Periodic update error: $e');
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeWallet() async {
    await _loadWallet();
    try {
      // Fetch selected network
      final network = await StorageHelper.getSelectedNetwork();
      if (network == null) {
        print('No network selected.');
        return;
      }

      setState(() {
        _networkName = network['name'] ?? 'BNB Network';
        _rpcUrl = network['rpc'] ?? 'https://bsc-dataseed.binance.org/';
      });

      // Fetch balance
      await _loadBalance();

      // Fetch transactions if balance > 0
      if (_balance > BigInt.zero) {
        await _fetchTransactions();
      }
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _loadWallet() async {
    String? walletAddress = await _storage.read(key: 'wallet_address');
    if (walletAddress == null) {
      walletAddress = await _bnbProvider.createWallet();
    }
    setState(() {
      _walletAddress = walletAddress!;
    });
    _loadBalance();
    _fetchTransactions();
  }

  Future<void> _loadBalance() async {
    final String tokenContractAddress =
        '0xCfA784a3E9e7E9C88a845Ab9AFA8f3B95fCDF5d0'; // Example token contract
    try {
      if (_selectedToken == 'BNB') {
        _balance = await _bnbProvider.getBalance(_walletAddress);
      } else {
        _balance = await _bnbProvider.getTokenBalance(
            _walletAddress, tokenContractAddress);
      }
      setState(() {});
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      // Fetch transactions from BscScan
      final transactions =
          await _bnbProvider.getTransactionHistory(_walletAddress);

      // Retrieve stored transactions
      final storedTransactions =
          await _bnbProvider.getStoredTransactions('bnb');

      setState(() {
        _transactions = storedTransactions.map((tx) {
          return {
            'blockNumber': tx['blockNumber'] ?? 'Unknown',
            'to': tx['to'] ?? 'Unknown',
            'value': BigInt.tryParse(tx['value'] ?? '0') ?? BigInt.zero,
            'hash': tx['hash'] ?? 'Unknown',
          };
        }).toList();
      });

      print('Fetched transactions: $_transactions');
      print('Total stored transactions: ${storedTransactions.length}');
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  void _logStoredPrivateKey() async {
    final privateKey = await _bnbProvider.exportWallet();
    if (privateKey != null) {
      print('Stored Private Key: $privateKey');
    } else {
      print('No private key found in storage.');
    }
  }

  void _showAddNetworkPopup() {
    showDialog(
      context: context,
      builder: (context) => AddNetworkPopup(
        onAdd: (name, rpc, chainId, symbol, explorer) {
          print('Network Added: $name');
        },
      ),
    );
  }

  void _showSwitchNetworkPopup() {
    showDialog(
      context: context,
      builder: (context) => SwitchNetworkPopup(
        onSwitch: (networkName, rpcUrl) {
          setState(() {
            _networkName = networkName;
          });
          print('Switched to $networkName');
        },
      ),
    );
  }

  void _showSendReceivePopup(String title) {
    showDialog(
      context: context,
      builder: (context) => SendReceivePopup(
        title: title,
        onSubmit: (address, amount) {
          print('$title $amount to $address');
        },
      ),
    );
  }

  void _exportWallet() async {
    final privateKey = await _bnbProvider.exportWallet();
    if (privateKey != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Export Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Private Key:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SelectableText(
                privateKey,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: privateKey));
                  Fluttertoast.showToast(
                    msg: 'Private key copied to clipboard!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
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

  void _importWallet() {
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
                Fluttertoast.showToast(msg: 'Wallet Imported!');
                await _initializeWallet(); // Reload wallet info
                Navigator.pop(context);
              } else {
                Fluttertoast.showToast(msg: 'Private key is empty!');
              }
            },
            child: Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeroSection(
            walletAddress: _walletAddress,
            balance: _balance,
            tokenSymbol: _selectedToken,
            networkName: _networkName,
            onCopyAddress: () => print('Copied Address'),
            onSend: () => _showSendReceivePopup('Send'),
            onReceive: () => _showSendReceivePopup('Receive'),
            onSwitchNetwork: _showSwitchNetworkPopup,
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Transactions'),
                      Tab(text: 'Import/Export Wallet'),
                    ],
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        TransactionList(
                          transactions: _transactions.map((tx) {
                            final amountInBNB = (tx['value'] as BigInt) /
                                BigInt.from(10).pow(18);
                            return {
                              ...tx,
                              'amountInBNB': amountInBNB.toString(),
                            };
                          }).toList(),
                        ),
                        ImportExportWallet(
                          onImport: _importWallet,
                          onExport: _exportWallet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
