import 'package:flutter/material.dart';

class DrawerMenuWidget extends StatelessWidget {
  final VoidCallback onClicked;
  const DrawerMenuWidget({
    Key? key,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onClicked,
        icon: Icon(Icons.align_horizontal_left),
        color: Color(0xFF17203A),
      );
}
