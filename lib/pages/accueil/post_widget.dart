import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/detail.dart';
import 'package:intl/intl.dart'; // Importez la bibliothèque intl

class PostWidget extends StatelessWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Projets').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(
              color: Colors.blue,
            );
          }

          var posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index].data() as Map<String, dynamic>;

              // Formatage de la date
              DateTime dateAjout = (post['dateAjout'] as Timestamp).toDate();
              String formattedDate = DateFormat('dd/MM/yyyy').format(dateAjout);

              // Récupérer la première ligne de la description
              String description = post['description'];
              String firstLine = description.split('\n')[0];

              return Card(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          imageUrl: post['image'],
                          freelanceName: post['nomClient'],
                          date: post['dateAjout'],
                          description: post['description'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage("lib/assets/google.png"),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['nomClient'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(formattedDate), // Affichez la date formatée
                              Text(
                                firstLine, // Affichez uniquement la première ligne
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Image.network(post['image']),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Action when "Detail" button is pressed
                            },
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              "Detail",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Action when "Enregistrer" button is pressed
                            },
                            icon: const Icon(
                              Icons.save,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
