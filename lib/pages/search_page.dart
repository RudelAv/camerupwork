import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/freelance_detail.dart';

class MyAppSearch extends StatefulWidget {
  final String userId;
  const MyAppSearch({super.key, required this.userId});

  @override
  State<MyAppSearch> createState() => _MyAppSearchState();
}

class _MyAppSearchState extends State<MyAppSearch> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchPage(
        userId: widget.userId,
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final String userId;
  const SearchPage({super.key, required this.userId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          actions: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20), // Bordures arrondies
                          color: Colors.grey[200],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Trouver des freelances",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                            suffixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelColor:
                Colors.blue, // Couleur bleue pour le texte de l'onglet actif
            tabs: [
              Tab(text: 'À distance'),
              Tab(text: 'En présentiel'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Contenu de l'onglet "À distance"
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .where('username', isGreaterThanOrEqualTo: searchQuery)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(doc.id)
                            .collection('freelance')
                            .doc(doc.id)
                            .get(),
                        builder: (context, freelanceSnapshot) {
                          if (freelanceSnapshot.hasError) {
                            return Text('Error: ${freelanceSnapshot.error}');
                          }

                          if (freelanceSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                          }

                          // Vérifier l'existence du document
                          if (freelanceSnapshot.hasData &&
                              freelanceSnapshot.data!.exists) {
                            final freelanceData = freelanceSnapshot.data!.data()
                                as Map<String, dynamic>;
                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('Avis')
                                  .where('freelanceId', isEqualTo: doc.id)
                                  .get(),
                              builder: (context, avisSnapshot) {
                                if (avisSnapshot.hasError) {
                                  return Text('Error: ${avisSnapshot.error}');
                                }

                                if (avisSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
                                }

                                // Calculer la moyenne des ratings
                                double averageRating = 0;
                                if (avisSnapshot.data!.docs.isNotEmpty) {
                                  averageRating = avisSnapshot.data!.docs
                                          .map((doc) =>
                                              (doc['rating'] as int).toDouble())
                                          .reduce((a, b) => a + b) /
                                      avisSnapshot.data!.docs.length.toDouble();
                                }

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FreelanceDetail(
                                          imageUrl:
                                              freelanceData['photoProfil'],
                                          name: doc['username'],
                                          date: "12 juin 2022",
                                          description:
                                              freelanceData['presentation'],
                                          userId: widget.userId,
                                          freelanceId: doc['id_user'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: NetworkImage(
                                          freelanceData['photoProfil']),
                                    ),
                                    title: Text(doc['username']),
                                    subtitle: Text(
                                        freelanceData['specialite'] ?? 'N/A'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          averageRating.toStringAsFixed(1),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return SizedBox
                                .shrink(); // Ne renvoie rien si le document n'existe pas
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Contenu de l'onglet "En présentiel"
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .where('username', isGreaterThanOrEqualTo: searchQuery)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];

                      // Vérifier si la sous-collection existe
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(doc.id)
                            .collection(
                                'TravailleurPresentiel') // Accédez à la sous-collection
                            .get(), // Récupérez tous les documents de la sous-collection
                        builder: (context, freelanceSnapshot) {
                          if (freelanceSnapshot.hasError) {
                            return Text('Error: ${freelanceSnapshot.error}');
                          }

                          if (freelanceSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                          }

                          // Vérifiez s'il y a des documents dans la sous-collection
                          if (freelanceSnapshot.hasData &&
                              freelanceSnapshot.data!.docs.isNotEmpty) {
                            // Sélectionnez le premier document de la sous-collection (vous pouvez choisir un autre document si besoin)
                            final freelanceData =
                                freelanceSnapshot.data!.docs.first.data()
                                    as Map<String, dynamic>;
                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('Avis')
                                  .where('freelanceId', isEqualTo: doc.id)
                                  .get(),
                              builder: (context, avisSnapshot) {
                                if (avisSnapshot.hasError) {
                                  return Text('Error: ${avisSnapshot.error}');
                                }

                                if (avisSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
                                }

                                // Calculer la moyenne des ratings
                                double averageRating = 0;
                                if (avisSnapshot.data!.docs.isNotEmpty) {
                                  averageRating = avisSnapshot.data!.docs
                                          .map((doc) => doc['rating'] as double)
                                          .reduce((a, b) => a + b) /
                                      avisSnapshot.data!.docs.length;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FreelanceDetail(
                                          imageUrl:
                                              freelanceData['imageUrl'] ?? '',
                                          name: doc['username'],
                                          date: "12 juin 2022",
                                          description:
                                              freelanceData['presentation'] ??
                                                  '',
                                          userId: widget.userId,
                                          freelanceId: freelanceSnapshot
                                              .data!.docs.first.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius:
                                          60, // Augmente le rayon du CircleAvatar à 30 (vous pouvez ajuster la valeur)
                                      backgroundImage: NetworkImage(
                                          freelanceData['imageUrl']),
                                    ),
                                    title: Text(doc['username']),
                                    subtitle: Text(
                                        freelanceData['activite'] ?? 'N/A'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          averageRating.toStringAsFixed(1),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return SizedBox
                                .shrink(); // Ne rendra rien si la sous-collection est vide
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
