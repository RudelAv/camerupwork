import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pfe/pages/accueil/conversation_group.dart';
import 'package:pfe/pages/accueil/freelance_detail.dart';

class RecruitJobDetail extends StatefulWidget {
  final String userId;
  final String projectId; // Ajoutez un attribut pour l'ID du projet
  // Supprimez l'attribut freelanceId car il n'est plus nécessaire

  const RecruitJobDetail(
      {super.key, required this.projectId, required this.userId});

  @override
  State<RecruitJobDetail> createState() => _RecruitJobDetailState();
}

class _RecruitJobDetailState extends State<RecruitJobDetail> {
  late DocumentSnapshot projectDocument;
  bool hasMultipleRecruitedCandidates = false; // Nouvelle variable
  String? conversationId;

  Future<DocumentSnapshot<Object?>> _fetchProjectDetails() async {
    try {
      projectDocument = await FirebaseFirestore.instance
          .collection('Projets')
          .doc(widget.projectId)
          .get();

      // Vérifiez le nombre de candidats recrutés
      final candidatesQuery = FirebaseFirestore.instance
          .collection('Projets')
          .doc(widget.projectId)
          .collection('Candidats')
          .where('recruté', isEqualTo: true);
      final candidateSnapshot = await candidatesQuery.get();

      hasMultipleRecruitedCandidates = candidateSnapshot.docs.length > 1;

      return projectDocument; // Retournez le document
    } catch (e) {
      print("Error fetching project details: $e");
      // Retournez un Future avec une erreur pour que FutureBuilder puisse gérer l'erreur
      throw Exception('Error fetching project details: $e');
    }
  }

  Future<String?> _getConversationId(
      List<QueryDocumentSnapshot> candidates) async {
    // Trie les IDs des participants par ordre alphabétique pour garantir un ID de conversation unique
    final sortedCandidateIds = candidates.map((doc) => doc.id).toList()..sort();

    // Concaténer les IDs des participants pour former l'ID de la conversation
    final conversationId = sortedCandidateIds.join('_');

    // Vérifiez si la conversation existe déjà
    final conversationDoc = await FirebaseFirestore.instance
        .collection('ConversationsProjet')
        .doc(conversationId)
        .get();

    if (conversationDoc.exists) {
      return conversationId;
    } else {
      // Créer la conversation si elle n'existe pas
      await FirebaseFirestore.instance
          .collection('ConversationsProjet')
          .doc(conversationId)
          .set({
        'participants': sortedCandidateIds, // Liste des participants
      });
      return conversationId;
    }
  }

  void _showTeamMembersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Projets')
                      .doc(widget.projectId)
                      .collection('Candidats')
                      .where('recruté', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData) {
                      final candidates = snapshot.data!.docs;

                      if (candidates.isEmpty) {
                        return const Center(
                            child: Text("Aucun membre d'équipe."));
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: candidates.length,
                              itemBuilder: (context, index) {
                                final candidateId = candidates[index].id;
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(candidateId)
                                      .get(),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const ListTile(
                                        title: Text("Chargement..."),
                                      );
                                    }

                                    if (userSnapshot.hasData) {
                                      final userData = userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                      String imageUrl = '';
                                      String activite = '';
                                      String specialite = '';
                                      String ville = '';

                                      // Récupérez les informations directement du document utilisateur
                                      imageUrl = userData['photoProfil'] ?? '';
                                      activite = userData['activite'] ?? '';
                                      specialite = userData['specialite'] ?? '';
                                      ville = userData['ville'] ??
                                          ''; // Vérifiez si 'ville' existe

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(imageUrl),
                                            ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(userData['username']),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FreelanceDetail(
                                                          imageUrl: imageUrl,
                                                          name: userData[
                                                              'username'],
                                                          date: '12/10/2023',
                                                          description: userData[
                                                              'presentation'],
                                                          userId: widget.userId,
                                                          freelanceId: userData[
                                                              'id_user'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text('Profil'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.blue,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    elevation: 2.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (activite.isNotEmpty)
                                                  Text('Activité: $activite'),
                                                if (specialite.isNotEmpty)
                                                  Text(
                                                      'Spécialité: $specialite'),
                                                if (ville.isNotEmpty)
                                                  Text('Ville: $ville'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    } else if (userSnapshot.hasError) {
                                      return ListTile(
                                        title: Text(
                                            "Erreur: ${userSnapshot.error}"),
                                      );
                                    }

                                    return const SizedBox();
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Passer la liste des candidats à la fonction de rappel
                                await _handleConversation(candidates);
                              },
                              child: Text("Conversation"),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text("Erreur: ${snapshot.error}");
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Fonction de rappel pour gérer la conversation
  Future<void> _handleConversation(
      List<QueryDocumentSnapshot<Object?>> candidates) async {
    // Générer l'ID de la conversation si elle n'existe pas encore
    if (conversationId == null) {
      conversationId = await _getConversationId(candidates);
    }

    // Navigation vers la page de conversation
    if (conversationId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationPage(
            conversationId: conversationId!, // Passez l'ID de la conversation
            userId: widget.userId, // Passez l'ID de l'utilisateur connecté
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: _fetchProjectDetails(), // Appel de la fonction async
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          projectDocument = snapshot.data!;
          Map<String, dynamic> projectData =
              projectDocument.data() as Map<String, dynamic>;

          // Formatage de la date
          DateTime dateAjout = (projectData['dateAjout'] as Timestamp).toDate();
          String formattedDate = DateFormat('dd/MM/yyyy').format(dateAjout);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Center(child: Text("Détails du projet")),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre du projet
                    Text(
                      projectData['titre'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Informations sur le client
                    Row(
                      children: [
                        // Image du client
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(projectData['image'] ?? ''),
                          radius: 30,
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              projectData['nomClient'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Publié le: $formattedDate'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Description du projet
                    Text(
                      'Description:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      projectData['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),

                    // Budget du projet
                    Text(
                      'Budget:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${projectData['Budget']} XAF',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),

                    // Type de travail
                    Text(
                      'Type de travail:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      projectData['typeTravail'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),

                    // Ville
                    if (projectData['typeTravail'] == 'Sur site')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ville:',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            projectData['ville'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      ),

                    // Catégorie
                    Text(
                      'Catégorie:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      projectData['categorie'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),

                    // Affichage du statut du projet
                    Text(
                      'Statut:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      projectData['statut'] ?? 'Non spécifié',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),

                    // Affichage du bouton "Les autres membres de l'équipe"
                    if (hasMultipleRecruitedCandidates)
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _showTeamMembersModal(context),
                          child: const Text('Les autres membres de l\'équipe'),
                        ),
                      )
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Erreur: ${snapshot.error}");
        }

        return const SizedBox();
      },
    );
  }
}
