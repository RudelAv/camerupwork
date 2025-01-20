import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/detail.dart';

class WorkersList extends StatefulWidget {
  final String activite;

  const WorkersList({required this.activite});

  @override
  _WorkersListState createState() => _WorkersListState();
}

class _WorkersListState extends State<WorkersList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .where('freelance', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final users = snapshot.data!.docs;
          final filteredUsers = users
              .where((user) =>
                  user.get('freelance').containsKey('activite') &&
                  user.get('freelance')['activite'].contains(widget.activite))
              .toList();

          if (filteredUsers.isEmpty) {
            return Center(
              child: Text('Aucun résultat trouvé'),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final username = user['username'];
                final photoProfil = user['freelance']['photoProfil'];
                final presentation = user['freelance']['presentation'];
                final idUser = user['id_user'];

                return FutureBuilder<double>(
                  future: calculateAverageRating(idUser),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final averageRating = snapshot.data!;
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => Detail(
                            //       imageUrl: photoProfil,
                            //       description: presentation,
                            //       activite: widget.activite,
                            //       nomActivite: username,
                            //       idUser: idUser,
                            //     ),
                            //   ),
                            // );
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(photoProfil),
                            radius: 30,
                          ),
                          title: Text(
                            username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (presentation.length > 200)
                                Text(
                                  presentation.substring(0, 200) + '...',
                                  style: TextStyle(fontSize: 12),
                                )
                              else
                                Text(
                                  presentation,
                                  style: TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$averageRating'),
                              Icon(Icons.star),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Erreur de récupération des notes');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          return Text('Une erreur s\'est produite');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<double> calculateAverageRating(String idUser) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Avis')
        .where('freelanceId', isEqualTo: idUser)
        .get();
    final ratings = querySnapshot.docs.map((doc) => doc['rating']).toList();
    if (ratings.isEmpty) {
      return 0.0;
    } else {
      return ratings.reduce((a, b) => a + b) / ratings.length;
    }
  }
}
