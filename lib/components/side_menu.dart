import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget{
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: Color(0xFF17203A),
        child: SafeArea(
          child: Column(
            children:[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(
                    CupertinoIcons.person,
                    color: Colors.white,

                  )
                ),
                title: Text(
                  "Kenfack Rudel",
                  style: TextStyle(color:Colors.white),
                ),
                subtitle: Text(
                  "Developpeur",
                  style: TextStyle(color:Colors.white),
                )
              )
            ]
          )
        )
      )
    );
  }
}
