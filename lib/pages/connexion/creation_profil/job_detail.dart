import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JobDetail extends StatefulWidget {
  final String projectId;
  final String freelanceId;

  const JobDetail(
      {super.key, required this.projectId, required this.freelanceId});

  @override
  State<JobDetail> createState() => _JobDetailState();
}

class _JobDetailState extends State<JobDetail> {
  late DocumentSnapshot projectDocument;

  @override
  void initState() {
    super.initState();
    _fetchProjectDetails();
  }

  Future<void> _fetchProjectDetails() async {
    try {
      projectDocument = await FirebaseFirestore.instance
          .collection('Projets')
          .doc(widget.projectId)
          .get();
      setState(() {});
    } catch (e) {
      print("Error fetching project details: $e");
    }
  }

  Future<void> _postuler() async {
    // Vérifiez si le freelance a déjà postulé au projet
    final candidateSnapshot = await FirebaseFirestore.instance
        .collection('Projets')
        .doc(widget.projectId)
        .collection('Candidats')
        .doc(widget.freelanceId) // Utilisez l'ID du freelance
        .get();

    if (candidateSnapshot.exists) {
      // Le freelance a déjà postulé
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Information'),
            content: const Text('Vous avez déjà postulé à ce projet.'),
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
    } else {
      // Récupérez les informations du freelance ou du travailleur en presentiel
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.freelanceId)
          .get();

      String username = userDoc.get('username');

      // Enregistrer le freelance ou le travailleur en presentiel comme candidat
      try {
        // Vérifiez le type de travail de l'utilisateur
        if (userDoc.get('typeTravail') == 'en ligne') {
          // Récupérez les informations du freelance
          final freelanceDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.freelanceId)
              .collection('freelance')
              .doc(widget.freelanceId)
              .get();

          if (freelanceDoc.exists) {
            final freelanceData = freelanceDoc.data() as Map<String, dynamic>;
            await FirebaseFirestore.instance
                .collection('Projets')
                .doc(widget.projectId)
                .collection('Candidats')
                .doc(widget.freelanceId) // Utilisez l'ID du freelance
                .set({
              'username': username,
              'photoProfil': freelanceData['photoProfil'],
              'activite': freelanceData['activite'],
              'specialite': freelanceData['specialite'],
            });
          }
        } else {
          // Récupérez les informations du travailleur en presentiel
          final sousCollectionSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.freelanceId)
              .collection('TravailleurPresentiel')
              .limit(1) // Limite la requête à un seul document
              .get();

          final premierDocument = sousCollectionSnapshot.docs.first;
          final premierDocumentId = premierDocument.id;

          final travailleurPresentielDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.freelanceId)
              .collection('TravailleurPresentiel')
              .doc(premierDocumentId) // Utilise l'ID du premier document
              .get();

          if (travailleurPresentielDoc.exists) {
            final travailleurPresentielData =
                travailleurPresentielDoc.data() as Map<String, dynamic>;
            // Utilisez l'ID du document dans 'TravailleurPresentiel' comme ID de candidat
            await FirebaseFirestore.instance
                .collection('Projets')
                .doc(widget.projectId)
                .collection('Candidats')
                .doc(widget.freelanceId)
                .set({
              'username': username,
              'photoProfil': travailleurPresentielData['imageUrl'],
              'activite': travailleurPresentielData['activite'],
              // 'specialite': specialite, // Pas de spécialité pour les travailleurs en presentiel
            });
          }
        }

        // Afficher un message de confirmation
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text('Vous avez postulé avec succès!'),
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
        print("Error submitting candidacy: $e");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              content: Text('Erreur lors de la soumission: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    if (projectDocument == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    backgroundImage: NetworkImage(projectData['image'] ?? ''),
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

              // Affichage du bouton Postuler ou du message
              if (projectData['statut'] == 'ouvert')
                Center(
                  child: ElevatedButton(
                    onPressed: _postuler,
                    child: const Text('Postuler'),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Les candidatures ne sont plus recevables pour ce projet.',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
