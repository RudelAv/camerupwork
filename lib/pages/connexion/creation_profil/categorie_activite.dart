import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart';
import 'package:pfe/pages/connexion/creation_profil/creation_profil.dart';
import 'package:pfe/pages/connexion/creation_profil/profilClient.dart';
import 'package:pfe/pages/connexion/creation_profil/profil_presentiel.dart';

class CategorieActivite extends StatefulWidget {
  final String username;
  final String email;
  final String userId;
  // final String notificationToken;

  const CategorieActivite({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
    // required this.notificationToken,
  });

  @override
  State<CategorieActivite> createState() => _CategorieActiviteState();
}

class _CategorieActiviteState extends State<CategorieActivite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('lib/assets/bg1.png'),
          fit: BoxFit.cover,
        )),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 70.0),
            child: Text(
              'CamerUpWork',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Bienvenue ${widget.username}!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Dans quelle Categorie exercez vous ?',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreationProfil(
                    userId: widget.userId,
                    // notificationToken: widget.notificationToken,
                  ),
                ),
              );
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'TRAVAIL EN LIGNE',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilPresentiel(userId: widget.userId),
                ),
              );
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'TRAVAIL EN PRESENTIEL',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profilclient(userId: widget.userId),
                ),
              );
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'Je suis un client',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          const Spacer(),
        ]),
      ),
    );
  }
}
