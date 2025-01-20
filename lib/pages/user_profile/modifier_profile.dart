import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/user_profile/bilan_page.dart';

class ModifierProfile extends StatefulWidget {
  final String userId;
  const ModifierProfile({super.key, required this.userId});

  @override
  State<ModifierProfile> createState() => _ModifierProfileState();
}

class _ModifierProfileState extends State<ModifierProfile> {
  late String username = 'Nom d\'utilisateur';
  late String email = 'Adresse Mail';
  late String photoUrl = 'lib/assets/th.jpg'; // Photo par défaut

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      setState(() {
        username = userDoc.get('username');
        email = userDoc.get('email');
        photoUrl = userDoc.get('photoProfil') ?? 'lib/assets/th.jpg';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Profile')),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Center(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(18)),
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage(photoUrl),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  username,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  email,
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () {},
                    child: Text(
                      "Modifier Profil",
                      style: TextStyle(color: Colors.white),
                    )),
                const SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMATIONS SUR LE COMPTE',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 220,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(198, 245, 243, 243),
                  ),
                  padding: EdgeInsets.only(
                      left: 16,
                      right: 16), // Ajouter un espacement à gauche et à droite
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Aligner les éléments à gauche
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize:
                              15, // Taille de police légèrement plus petite
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Couleur noire
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Nom d\'Utilisateur',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.grey,
                        thickness: 1, // Épaisseur du trait plus fine
                        indent: 0, // Espacement à gauche et à droite
                        endIndent: 0,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize:
                              15, // Taille de police légèrement plus petite
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Couleur noire
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Adresse Mail',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.grey,
                        thickness: 1, // Épaisseur du trait plus fine
                        indent: 0, // Espacement à gauche et à droite
                        endIndent: 0,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BilanPage()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mon Bilan',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios, // Icône de "suivant"
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.grey,
                        thickness: 1, // Épaisseur du trait plus fine
                        indent: 0, // Espacement à gauche et à droite
                        endIndent: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion du Compte',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 60,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(198, 245, 243, 243),
                  ),
                  padding: EdgeInsets.only(
                      left: 16,
                      right: 16), // Ajouter un espacement à gauche et à droite
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Aligner les éléments à gauche
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Desactivation et Suppression',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios, // Icône de "suivant"
                            size: 20,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.grey,
                        thickness: 1, // Épaisseur du trait plus fine
                        indent: 0, // Espacement à gauche et à droite
                        endIndent: 0,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    height: 60,
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16), // Ajouter une marge à gauche
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.logout, // Icône de déconnexion
                                  size: 20,
                                  color: Colors.red, // Couleur rouge
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Se déconnecter',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red, // Couleur rouge
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
