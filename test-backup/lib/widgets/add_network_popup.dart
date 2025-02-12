import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';

class AddNetworkPopup extends StatelessWidget {
  final Function(String name, String rpc, String chainId, String symbol,
      String explorer) onAdd;

  AddNetworkPopup({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController rpcController = TextEditingController();
    final TextEditingController chainIdController = TextEditingController();
    final TextEditingController symbolController = TextEditingController();
    final TextEditingController explorerController = TextEditingController();

    return AlertDialog(
      title: Text('Add Network', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Network Name'),
            ),
            TextField(
              controller: rpcController,
              decoration: InputDecoration(labelText: 'RPC URL'),
            ),
            TextField(
              controller: chainIdController,
              decoration: InputDecoration(labelText: 'Chain ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: symbolController,
              decoration: InputDecoration(labelText: 'Symbol'),
            ),
            TextField(
              controller: explorerController,
              decoration: InputDecoration(labelText: 'Explorer URL'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Create a network map with explicit Map<String, String> type
            final Map<String, String> network = {
              'name': nameController.text.trim(),
              'rpc': rpcController.text.trim(),
              'chainId': chainIdController.text.trim(),
              'symbol': symbolController.text.trim(),
              'explorer': explorerController.text.trim(),
            };

            // Save the network to storage
            await StorageHelper.saveSelectedNetwork(network);
            print('Network Added: $network');

            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
