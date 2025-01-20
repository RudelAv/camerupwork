import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart'; // Importez FirebaseAuth

class ProfilPresentiel extends StatefulWidget {
  final String userId;
  ProfilPresentiel({super.key, required this.userId});

  @override
  State<ProfilPresentiel> createState() => _ProfilPresentielState();
}

class _ProfilPresentielState extends State<ProfilPresentiel> {
  // Initial values for the form fields
  String? selectedActivite;
  String? selectedVille;
  File? profileImage;
  String? descriptionActivite;

  // List of activities and cities for the dropdown menus
  final List<String> activites = [
    'Plomberie',
    'Charpenterie',
    'Soudure',
    'Menuiserie',
    'Artisanat',
    'Construction'
  ];
  final List<String> villes = [
    'Yaoundé',
    'Douala',
    'Garoua',
    'Bamenda',
    'Maroua',
    'Bertoua',
    'Kumba',
    'Ebolowa',
    'Bafoussam',
    'Nkongsamba',
    'Limbe',
    'Kribi',
    'Buea',
    'Dschang'
  ];

  // Function to pick an image from the gallery or camera
  Future<void> _getImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        profileImage = File(pickedImage.path);
      });
    }
  }

  // Function to handle the form submission
  Future<void> _submitForm() async {
    if (selectedActivite == null ||
        selectedVille == null ||
        descriptionActivite == null) {
      // Handle validation errors (e.g., show an error message)
      return;
    }

    // Upload the image to Firebase Storage
    String? imageUrl;
    if (profileImage != null) {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child(widget.userId)
          .child('profile_image.jpg');
      await storageRef.putFile(profileImage!);
      imageUrl = await storageRef.getDownloadURL(); // Récupérez l'URL
    }

    // Create the document in Firestore
    final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('TravailleurPresentiel')
        .doc();
    await docRef.set({
      'activite': selectedActivite,
      'ville': selectedVille,
      'descriptionActivite':
          descriptionActivite, // Ajout du champ de description
      'id_user': widget.userId,
      'imageUrl': imageUrl, // Insérez l'URL de l'image
    });

    // Mettre à jour le document de l'utilisateur dans la collection 'Users'
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .update({
      'typeTravail': 'en presentiel', // Mettre à jour le champ 'typeTravail'
    });

    // Navigate to MyHomePage after successful submission
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MyHomePage(
                userId: widget.userId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un profil'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circle Avatar
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Galerie'),
                          onTap: () {
                            _getImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Caméra'),
                          onTap: () {
                            _getImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Activite Dropdown Menu
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Activité',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: selectedActivite,
              hint: const Text('Sélectionnez une activité'),
              items: activites.map((activite) {
                return DropdownMenuItem(
                  value: activite,
                  child: Text(activite),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedActivite = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Ville Dropdown Menu
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: selectedVille,
              hint: const Text('Sélectionnez une ville'),
              items: villes.map((ville) {
                return DropdownMenuItem(
                  value: ville,
                  child: Text(ville),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVille = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Description de l'activité
            TextField(
              decoration: InputDecoration(
                labelText: 'Description de l\'activité',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  descriptionActivite = value;
                });
              },
            ),
            const SizedBox(height: 30),
            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  'Envoyer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
