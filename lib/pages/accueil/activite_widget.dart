import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/activite-recherce.dart';
import 'package:pfe/pages/accueil/detail.dart';

class ActivityWidget extends StatelessWidget {
  final String userId;
  const ActivityWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Activites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final activites = snapshot.data!.docs;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: activites.length,
              itemBuilder: (context, index) {
                final activite = activites[index];
                final nomActivite = activite['nomActivite'];
                final imageUrl = activite['image'];
                final description = activite['description'];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Activite_recherche(
                          imageUrl: imageUrl,
                          description: description,
                          activite: nomActivite,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: Image.network(imageUrl),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            nomActivite,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Une erreur s\'est produite');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
