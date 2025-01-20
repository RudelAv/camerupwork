import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart';

class Profilclient extends StatefulWidget {
  final String userId;

  const Profilclient({super.key, required this.userId});

  @override
  State<Profilclient> createState() => _ProfilclientState();
}

class _ProfilclientState extends State<Profilclient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageToFirestore() async {
    if (_image == null) {
      // Gérer le cas où aucune image n'a été sélectionnée
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final storageRef =
          FirebaseStorage.instance.ref().child("user_images/$userId");

      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("Users").doc(userId).update({
        "photoProfil": downloadUrl,
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Photo de profil mise à jour avec succès")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(userId: widget.userId),
        ),
      );
    } else {
      // Gérer le cas où l'utilisateur n'est pas connecté
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affichage de l'image sélectionnée
            if (_image != null) Image.file(_image!, height: 200, width: 200),

            // Bouton pour choisir une image de la galerie
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.gallery),
              child: const Text("Choisir une photo de la galerie"),
            ),

            const SizedBox(
              height: 20,
            ),

            // Bouton pour prendre une photo avec la caméra
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.camera),
              child: const Text("Prendre une photo"),
            ),

            const SizedBox(
              height: 20,
            ),

            // Bouton pour télécharger l'image dans Firestore
            ElevatedButton(
              onPressed: _uploadImageToFirestore,
              child: const Text("Télécharger la photo"),
            ),
          ],
        ),
      ),
    );
  }
}
