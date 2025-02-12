import 'package:flutter/material.dart';

class SendReceivePopup extends StatelessWidget {
  final String title;
  final Function(String address, String amount) onSubmit;

  SendReceivePopup({required this.title, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    return AlertDialog(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Recipient Address'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
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
          onPressed: () {
            onSubmit(addressController.text, amountController.text);
            Navigator.pop(context);
          },
          child: Text('Send'),
        ),
      ],
    );
  }
}
