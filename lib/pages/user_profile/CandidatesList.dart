import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pfe/pages/accueil/freelance_detail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CandidatesList extends StatefulWidget {
  final String projectId;
  final String userId;

  const CandidatesList(
      {Key? key, required this.projectId, required this.userId});

  @override
  State<CandidatesList> createState() => _CandidatesListState();
}

class _CandidatesListState extends State<CandidatesList> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _notificationSent = false;

  Future<void> _recruter(String freelanceId) async {
    try {
      // Mettez à jour le statut du freelance dans la collection 'Projets'
      await FirebaseFirestore.instance
          .collection('Projets')
          .doc(widget.projectId)
          .collection('Candidats')
          .doc(freelanceId)
          .update({'recruté': true});

      // Récupérez le token de notification du freelance
      final freelanceDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(freelanceId)
          .get();

      final token = freelanceDoc.get('notificationToken');

      // Ajoutez le projet à la sous-collection du freelance
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(freelanceId)
          .collection('MesProjets')
          .doc(widget.projectId)
          .set({
        'projectId': widget.projectId,
        'titre': await FirebaseFirestore.instance
            .collection('Projets')
            .doc(widget.projectId)
            .get()
            .then((doc) => doc.get('titre')), // Récupérez le titre du projet
        'statut': await FirebaseFirestore.instance
            .collection('Projets')
            .doc(widget.projectId)
            .get()
            .then((doc) => doc.get('statut')), // Récupérez le statut du projet
        // Vous pouvez ajouter d'autres informations si nécessaire
      });

      // Afficher un message de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Freelance recruté avec succès!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Afficher un message d'erreur
      print("Error recruting freelance: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: Text('Erreur lors du recrutement: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Gérer les messages en arrière-plan
    print("Message reçu en arrière-plan: ${message.data}");

    setState(() {
      _notificationSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Candidats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Projets')
            .doc(widget.projectId)
            .collection('Candidats')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            ));
          }

          if (snapshot.hasData) {
            final candidates = snapshot.data!.docs;

            if (candidates.isEmpty) {
              return const Center(
                child: Text("Aucun candidat pour le moment."),
              );
            }

            return ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidateData =
                    candidates[index].data() as Map<String, dynamic>;

                final freelanceId =
                    candidates[index].id; // Récupérez l'ID du candidat

                // Vérifiez si le freelance est déjà recruté
                final isRecruted = candidateData['recruté'] ?? false;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FreelanceDetail(
                          name: candidateData['username'],
                          date: '',
                          description: candidateData['presentation'] ?? '',
                          userId: widget.userId,
                          freelanceId: freelanceId, // Passez l'ID du freelance
                          imageUrl: candidateData['photoProfil'] ?? '',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(candidateData['photoProfil']),
                      ),
                      title: Text(candidateData['username']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Activité: ${candidateData['activite']}"),
                          Text("Spécialité: ${candidateData['specialite']}"),
                        ],
                      ),
                      trailing: isRecruted
                          ? Text(
                              'Recruté',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.person_add),
                              onPressed: () {
                                _recruter(freelanceId);
                              },
                            ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Erreur: ${snapshot.error}");
          }

          return const SizedBox();
        },
      ),
    );
  }
}
