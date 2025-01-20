import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pfe/widget/drawer_menu_widget.dart';
import 'package:image_picker/image_picker.dart';

class ProfilPage extends StatelessWidget {
  final VoidCallback openDrawer;
  const ProfilPage({
    super.key,
    required this.openDrawer,
  });
  // Fonction pour afficher le dialogue de sélection d'image
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir une source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Caméra'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Galerie'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fonction pour obtenir l'image et la convertir en ImageProvider
  Future<ImageProvider?> _getImage(BuildContext context) async {
    final ImageSource? source = await _showImageSourceDialog(context);
    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        return FileImage(File(pickedFile.path));
      }
    }
    return null;
  }

  // const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: DrawerMenuWidget(
          onClicked: openDrawer,
        ),
        elevation: 0,
        flexibleSpace: Center(
          child: Builder(
            builder: (BuildContext context) {
              // Builder pour accéder au context
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        AssetImage('assets/images/placeholder.png'),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImageProvider? newImage = await _getImage(context);
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Nom d\'utilisateur',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'email@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          // Ajoutez ici les informations relatives au compte de l'utilisateur
          // Exemple:
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Informations personnelles'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paramètres'),
          ),
          // ... autres informations
        ],
      ),
    );
  }
}
