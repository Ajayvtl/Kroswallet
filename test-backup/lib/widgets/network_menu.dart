import 'package:flutter/material.dart';

class NetworkMenu extends StatelessWidget {
  final Function onAddNetwork;

  NetworkMenu({required this.onAddNetwork});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => onAddNetwork(),
        ),
      ],
    );
  }
}
