import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;

class BnbProvider {
  final String _rpcUrl;
  final storage = FlutterSecureStorage();
  final String _bscScanApiKey;

  late Web3Client client;
  BnbProvider(this._rpcUrl, this._bscScanApiKey) {
    client = Web3Client(_rpcUrl, http.Client());
    print('BnbProvider initialized with RPC URL: $_rpcUrl');
  }
  // Constructor to initialize the client dynamically
  // BnbProvider(this._rpcUrl) {
  //   client = Web3Client(_rpcUrl, http.Client());
  // }

  // Create a new wallet and store its details securely
  Future<String> createWallet() async {
    final rng = Random.secure();
    final credentials = EthPrivateKey.createRandom(rng);

    final walletAddress = credentials.address.hex;
    final privateKeyHex = HEX.encode(credentials.privateKey);
    final encryptedKey = base64.encode(HEX.decode(privateKeyHex));

    // Get the latest block number
    final latestBlock = await getLatestBlockNumber();

    // Save wallet and block details
    await storage.write(key: 'wallet_address', value: walletAddress);
    await storage.write(key: 'private_key', value: encryptedKey);
    await storage.write(
        key: 'last_searched_block', value: latestBlock.toString());

    return walletAddress;
  }

  // Retrieve the wallet address from storage
  Future<String?> getWalletAddress() async {
    return await storage.read(key: 'wallet_address');
  }

  // Import an existing wallet using a private key
  Future<void> importWallet(String privateKey) async {
    final credentials = EthPrivateKey.fromHex(privateKey);
    final walletAddress = credentials.address.hex;

    final encryptedKey = base64.encode(HEX.decode(privateKey));
    final latestBlock = await getLatestBlockNumber();

    await storage.write(key: 'wallet_address', value: walletAddress);
    await storage.write(key: 'private_key', value: encryptedKey);
    await storage.write(
        key: 'last_searched_block', value: latestBlock.toString());
  }

  // Fetch the wallet's balance in the selected network
  Future<BigInt> getBalance(String walletAddress) async {
    final address = EthereumAddress.fromHex(walletAddress);
    final balance = await client.getBalance(address);
    return balance.getInWei;
  }

  // Fetch token balance for a specific contract
  Future<BigInt> getTokenBalance(
      String walletAddress, String tokenContractAddress) async {
    final address = EthereumAddress.fromHex(walletAddress);
    final contract = DeployedContract(
      ContractAbi.fromJson(tokenAbi, 'Token'),
      EthereumAddress.fromHex(tokenContractAddress),
    );
    final function = contract.function('balanceOf');
    final result = await client
        .call(contract: contract, function: function, params: [address]);
    return result.first as BigInt;
  }

  // Fetch the latest block number from the RPC
  Future<int> getLatestBlockNumber() async {
    final response = await http.post(
      Uri.parse(_rpcUrl), // Use the stored RPC URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'eth_blockNumber',
        'params': [],
        'id': 1,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['result'];
      return int.parse(result.replaceFirst('0x', ''), radix: 16);
    } else {
      throw Exception('Error fetching latest block number');
    }
  }

  // Fetch transaction history using BscScan API
  Future<List<Map<String, dynamic>>> getTransactionHistory(String walletAddress,
      {int page = 1, int offset = 10}) async {
    final url = Uri.parse(
        'https://api.bscscan.com/api?module=account&action=txlist&address=$walletAddress&startblock=0&endblock=99999999&page=$page&offset=$offset&sort=asc&apikey=$_bscScanApiKey');

    print('Fetching transactions for $walletAddress using URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('API Response: $data');

      if (data['status'] == '1') {
        final List<Map<String, dynamic>> transactions =
            List<Map<String, dynamic>>.from(data['result']);

        print('Fetched ${transactions.length} transactions from API.');

        // Save transactions to storage
        await saveTransactions('bnb', transactions);

        return transactions;
      } else {
        print('Error from BscScan API: ${data['message']}');
        return [];
      }
    } else {
      print('HTTP error: ${response.statusCode}');
      throw Exception('Failed to fetch transactions from BscScan.');
    }
  }
  // Fetch transaction history using BscScan API
  // Future<List<Map<String, dynamic>>> getTransactionHistory(
  //     String walletAddress) async {
  //   final url = Uri.parse(
  //     'https://api.bscscan.com/api?module=account&action=txlist&address=$walletAddress&startblock=0&endblock=99999999&sort=asc&apikey=$_bscScanApiKey',
  //   );

  //   print('Fetching transactions for $walletAddress from BscScan API: $url');

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     print('BscScan API response: $data');
  //     if (data['status'] == '1') {
  //       final List<Map<String, dynamic>> transactions =
  //           List<Map<String, dynamic>>.from(data['result']);
  //       print('Fetched ${transactions.length} transactions from API');
  //       return transactions;
  //     } else {
  //       print('BscScan API error: ${data['message']}');
  //       return [];
  //     }
  //   } else {
  //     print(
  //         'Failed to fetch transactions from BscScan API. Status code: ${response.statusCode}');
  //     return [];
  //   }
  // }

  // Future<List<Map<String, dynamic>>> getTransactionHistory(
  //     String walletAddress) async {
  //   final url = Uri.parse(
  //     'https://api.bscscan.com/api?module=account&action=txlist&address=$walletAddress&startblock=0&endblock=99999999&sort=asc&apikey=$_bscScanApiKey',
  //   );

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (data['status'] == '1') {
  //       final List<Map<String, dynamic>> transactions =
  //           List<Map<String, dynamic>>.from(data['result']);

  //       print('Fetched ${transactions.length} transactions for $walletAddress');

  //       // Save transactions to secure storage
  //       await saveTransactions('bnb', transactions);

  //       return transactions;
  //     } else {
  //       print('No transactions found or error: ${data['message']}');
  //       return [];
  //     }
  //   } else {
  //     throw Exception('Failed to fetch transactions from BscScan');
  //   }
  // }
  // // Fetch transaction history for a wallet in an optimized way
//   Future<List<Map<String, dynamic>>> getTransactionHistory(
//       String walletAddress) async {
//     final List<Map<String, dynamic>> transactions = [];
//     final address = EthereumAddress.fromHex(walletAddress);

//     // Fetch the latest and last searched blocks
//     final latestBlock = await getLatestBlockNumber();
//     // final lastSearchedBlockStr =
//     //     await storage.read(key: 'last_searched_block') ?? '0';
//     const String startBlockForTesting = '45586100';
//     // final lastSearchedBlockStr = '45586100';
//     int lastSearchedBlock = int.parse(startBlockForTesting);

//     print(
//         'Fetching transactions for $walletAddress from block $lastSearchedBlock to $latestBlock');

//     const int blockChunkSize = 10;

//     while (lastSearchedBlock < latestBlock) {
//       final endBlock =
//           (lastSearchedBlock + blockChunkSize).clamp(0, latestBlock);

//       print('Fetching blocks from $lastSearchedBlock to $endBlock');

//       // Fetch transactions in the current chunk
//       final chunkTransactions = await _fetchTransactionsInBlocks(
//           walletAddress, lastSearchedBlock, endBlock);

//       transactions.addAll(chunkTransactions);

//       // Update the last searched block
//       lastSearchedBlock = endBlock;
// // Save transactions to storage
//       await saveTransactions('bnb', chunkTransactions);
//       // Save progress to permanent storage
//       await storage.write(
//           key: 'last_searched_block', value: lastSearchedBlock.toString());
//       final storedTransactions = await getStoredTransactions('bnb');
//       print('Total stored transactions for BNB: ${storedTransactions.length}');
//     }

//     return transactions;
//   }

  // Helper to fetch transactions in a block range
  Future<List<Map<String, dynamic>>> _fetchTransactionsInBlocks(
      String walletAddress, int startBlock, int endBlock) async {
    final List<Map<String, dynamic>> transactions = [];
    final batchRequest = <Map<String, dynamic>>[];

    for (int block = startBlock; block <= endBlock; block++) {
      batchRequest.add({
        'jsonrpc': '2.0',
        'method': 'eth_getBlockByNumber',
        'params': ['0x${block.toRadixString(16)}', true],
        'id': block,
      });
    }

    // Send batch request
    final response = await http.post(
      Uri.parse(_rpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(batchRequest),
    );

    if (response.statusCode == 200) {
      final batchResponses = jsonDecode(response.body) as List;

      for (final blockData in batchResponses) {
        final block = blockData['result'];
        if (block == null) continue;
        print('Processing block: ${block['number']}');
        for (final tx in block['transactions']) {
          if (tx['from'] == walletAddress || tx['to'] == walletAddress) {
            print('Transaction found in block ${block['number']}: $tx');
            transactions.add({
              'from': tx['from'],
              'to': tx['to'] ?? 'Contract Creation',
              'amount': BigInt.parse(tx['value'].replaceFirst('0x', ''),
                      radix: 16)
                  .toString(), // Convert BigInt to String              'hash': tx['hash'],
              'timestamp': int.parse(block['timestamp'].replaceFirst('0x', ''),
                  radix: 16),
            });
          }
        }
      }
    } else {
      print('Error fetching blocks: ${response.statusCode}');
    }

    return transactions;
  }

  // Future<void> saveTransactions(
  //     String networkName, List<Map<String, dynamic>> transactions) async {
  //   final key = 'transactions_$networkName';
  //   final existingData = await storage.read(key: key);
  //   final existingTransactions = existingData != null
  //       ? List<Map<String, dynamic>>.from(jsonDecode(existingData))
  //       : [];

  //   // Add logs to check existing and new transactions
  //   print(
  //       'Existing transactions for $networkName: ${existingTransactions.length}');
  //   print('New transactions to save: ${transactions.length}');

  //   final allTransactions = [...existingTransactions, ...transactions];
  //   await storage.write(key: key, value: jsonEncode(allTransactions));

  //   print('Saved ${transactions.length} transactions for network $networkName');
  // }
  // Save transactions to secure storage
  // Future<void> saveTransactions(
  //     String networkName, List<Map<String, dynamic>> transactions) async {
  //   final key = 'transactions_$networkName';
  //   final existingData = await storage.read(key: key);
  //   final existingTransactions = existingData != null
  //       ? List<Map<String, dynamic>>.from(jsonDecode(existingData))
  //       : [];

  //   print(
  //       'Existing transactions for $networkName: ${existingTransactions.length}');
  //   print('New transactions to save: ${transactions.length}');

  //   final allTransactions = [...existingTransactions, ...transactions];
  //   await storage.write(key: key, value: jsonEncode(allTransactions));

  //   print('Saved ${transactions.length} transactions for network $networkName');
  // }
  Future<void> saveTransactions(
      String networkName, List<Map<String, dynamic>> transactions) async {
    final key = 'transactions_$networkName';
    final existingData = await storage.read(key: key);
    final existingTransactions = existingData != null
        ? List<Map<String, dynamic>>.from(jsonDecode(existingData))
        : [];

    // Deduplicate transactions by hash
    final allTransactions = [
      ...existingTransactions,
      ...transactions.where((newTx) => !existingTransactions
          .any((existingTx) => existingTx['hash'] == newTx['hash'])),
    ];

    // Sort by block number (descending)
    allTransactions.sort((a, b) =>
        int.parse(b['blockNumber'] ?? '0') -
        int.parse(a['blockNumber'] ?? '0'));

    await storage.write(key: key, value: jsonEncode(allTransactions));

    print('Saved ${transactions.length} transactions for network $networkName');
    print(
        'Total unique transactions for $networkName: ${allTransactions.length}');
  }

  // Future<List<Map<String, dynamic>>> getStoredTransactions(
  //     String networkName) async {
  //   final key = 'transactions_$networkName';
  //   final data = await storage.read(key: key);
  //   return data != null
  //       ? List<Map<String, dynamic>>.from(jsonDecode(data))
  //       : [];
  // }
  // Retrieve stored transactions from secure storage
  // Future<List<Map<String, dynamic>>> getStoredTransactions(
  //     String networkName) async {
  //   final key = 'transactions_$networkName';
  //   final data = await storage.read(key: key);
  //   return data != null
  //       ? List<Map<String, dynamic>>.from(jsonDecode(data))
  //       : [];
  // }
  // Retrieve stored transactions
  Future<List<Map<String, dynamic>>> getStoredTransactions(
      String networkName) async {
    final key = 'transactions_$networkName';
    final data = await storage.read(key: key);
    return data != null
        ? List<Map<String, dynamic>>.from(jsonDecode(data))
        : [];
  }

  // Export the wallet private key
  Future<String?> exportWallet() async {
    final encryptedPrivateKey = await storage.read(key: 'private_key');
    if (encryptedPrivateKey != null) {
      try {
        // Attempt to decode as base64
        final decodedPrivateKey =
            utf8.decode(base64.decode(encryptedPrivateKey));
        print('Exporting Private Key (Decoded): $decodedPrivateKey');
        return decodedPrivateKey;
      } catch (e) {
        // Fallback: Assume plain text if decoding fails
        print('Error decoding private key: $e. Assuming plain text format.');
        return encryptedPrivateKey; // Return raw key if not encoded
      }
    } else {
      print('No private key found in storage.');
    }
    return null;
  }
}

// Replace with actual token ABI JSON
// Replace with actual Shree Token ABI JSON
const tokenAbi = '''
[
  {
    "inputs": [],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "owner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "spender",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "Approval",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "Burn",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "Transfer",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "_decimals",
    "outputs": [
      {
        "internalType": "uint8",
        "name": "",
        "type": "uint8"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "_name",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "_symbol",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "_totalSupply",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "spender",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "approve",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "owner",
        "type": "address"
      }
    ],
    "name": "balanceOf",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "burn",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "burnFrom",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "changeOwner",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "decimals",
    "outputs": [
      {
        "internalType": "uint8",
        "name": "",
        "type": "uint8"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "name",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "symbol",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "totalSupply",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "transfer",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "transferFrom",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
''';
