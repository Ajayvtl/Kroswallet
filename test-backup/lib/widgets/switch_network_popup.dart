import 'package:flutter/material.dart';

class SwitchNetworkPopup extends StatelessWidget {
  final Function(String networkName, String rpcUrl) onSwitch;

  SwitchNetworkPopup({required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final predefinedNetworks = [
      {'name': 'BNB Network', 'rpc': 'https://bsc-dataseed.binance.org'},
      {
        'name': 'Ethereum',
        'rpc': 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY'
      },
      {'name': 'Kroschain', 'rpc': 'https://kroschain.com'},
    ];

    return AlertDialog(
      title:
          Text('Switch Network', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: predefinedNetworks.map((network) {
          return ListTile(
            title: Text(network['name']!),
            onTap: () {
              onSwitch(network['name']!, network['rpc']!);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
