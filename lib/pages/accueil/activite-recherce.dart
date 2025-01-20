import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/freelance_detail.dart';

class Activite_recherche extends StatefulWidget {
  final String imageUrl;
  final String description;
  final String activite;
  final String userId;

  const Activite_recherche({
    Key? key,
    required this.imageUrl,
    required this.description,
    required this.activite,
    required this.userId,
  }) : super(key: key);

  @override
  _Activite_rechercheState createState() => _Activite_rechercheState();
}

class _Activite_rechercheState extends State<Activite_recherche> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.activite),
      ),
      body: Column(
        children: [
          // Display the activity image and description
          Image.network(widget.imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.description),
          ),
          // Fetch and display the list of freelancers for the selected activity
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length, // Iterate through Users
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final username =
                          user['username']; // Get username from Users
                      final userId = user['id_user'];
                      final freelanceDocs = user.reference
                          .collection('freelance')
                          .where('activite', isEqualTo: widget.activite)
                          .snapshots();

                      return StreamBuilder<QuerySnapshot>(
                        stream: freelanceDocs,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final freelanceDocs = snapshot.data!.docs;
                            if (freelanceDocs.isNotEmpty) {
                              final freelancer = freelanceDocs.first;
                              final photoProfil = freelancer['photoProfil'];
                              final presentation = freelancer['presentation'];

                              // Split the presentation into lines
                              final lines = presentation.split('\n');
                              // Get the first line
                              final firstLine =
                                  lines.isNotEmpty ? lines.first : "";

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FreelanceDetail(
                                        imageUrl: photoProfil,
                                        description: presentation,
                                        name: username,
                                        date: '',
                                        userId: widget.userId,
                                        freelanceId: userId,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  clipBehavior:
                                      Clip.antiAlias, // Rounded corners
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Photo de profil with same height as Expanded
                                      Expanded(
                                        flex: 1, // Adjust as needed
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Image.network(
                                            photoProfil,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      // Other details
                                      Expanded(
                                        flex: 2, // Adjust as needed
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Rating
                                              Row(
                                                children: [
                                                  Text('4.5',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.yellow,
                                                    size: 18,
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              // Presentation
                                              Text(
                                                firstLine,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              SizedBox(height: 8),
                                              // Username
                                              Text(
                                                username,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // No freelancer found
                            }
                          } else if (snapshot.hasError) {
                            return Text('Une erreur s\'est produite');
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
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
          ),
        ],
      ),
    );
  }
}
