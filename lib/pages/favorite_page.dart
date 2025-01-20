import 'package:flutter/material.dart';
import 'package:pfe/widget/drawer_menu_widget.dart';

class FavoritePage extends StatelessWidget {
  final VoidCallback openDrawer;
  const FavoritePage({
    super.key,
    required this.openDrawer,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: DrawerMenuWidget(
            onClicked: openDrawer,
          ),
          title: Text('Favorite Page'),
        ),
      );
}
