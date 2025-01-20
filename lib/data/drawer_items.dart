import 'package:flutter/material.dart';
import 'package:pfe/models/drawer_item.dart';

class DrawerItems {
  static const home = DrawerItem(title: 'Accueil', icon: Icons.home);
  static const profile =
      DrawerItem(title: 'Profil', icon: Icons.usb_off_rounded);
  static const settings = DrawerItem(title: 'Parametres', icon: Icons.settings);
  static const logout = DrawerItem(title: 'logout', icon: Icons.logout);
  static const message = DrawerItem(title: 'message', icon: Icons.message);
  static const jobs =
      DrawerItem(title: 'creer un projet', icon: Icons.add_circle_rounded);
  static const userjobs =
      DrawerItem(title: 'Mes Projets', icon: Icons.list_alt);

  static final List<DrawerItem> all = [
    home,
    profile,
    settings,
    logout,
    message,
    jobs,
    userjobs
  ];
}
