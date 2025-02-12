import 'package:flutter/material.dart';

class ImportExportWallet extends StatelessWidget {
  final Function onImport;
  final Function onExport;

  ImportExportWallet({required this.onImport, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => onExport(),
            icon: Icon(Icons.upload),
            label: Text('Export Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => onImport(),
            icon: Icon(Icons.download),
            label: Text('Import Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
