import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pfe/pages/accueil/detail.dart';
import 'package:intl/intl.dart';
import 'package:pfe/pages/connexion/creation_profil/job_detail.dart'; // Importez la bibliothèque intl
import 'package:firebase_auth/firebase_auth.dart'; // Importez FirebaseAuth

class SearchWork extends StatefulWidget {
  final String userId;
  const SearchWork({Key? key, required this.userId});

  @override
  State<SearchWork> createState() => _SearchWorkState();
}

class _SearchWorkState extends State<SearchWork> {
  late List<DocumentSnapshot> projects;
  late List<DocumentSnapshot> filteredProjects = [];
  String?
      userWorkType; // Variable pour stocker le type de travail de l'utilisateur

  @override
  void initState() {
    super.initState();
    filteredProjects = [];
    _fetchUserWorkType(); // Récupérer le type de travail de l'utilisateur au démarrage
  }

  Future<void> _fetchUserWorkType() async {
    // Récupérer le type de travail de l'utilisateur connecté
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      setState(() {
        userWorkType = userDoc['typeTravail'];
      });
    }
  }

  void searchProjects(String searchText) {
    setState(() {
      filteredProjects = projects.where((project) {
        final title = project['titre'].toString().toLowerCase();
        final description = project['description'].toString().toLowerCase();
        final clientName = project['nomClient'].toString().toLowerCase();
        final date = project['dateAjout']
            .toString()
            .toLowerCase(); // Utilisez 'dateAjout'
        final projectWorkType = project['typeTravail'].toString().toLowerCase();

        // Vérifiez si le type de travail du projet correspond au type de travail de l'utilisateur
        bool workTypeMatch = userWorkType == null ||
            (projectWorkType == 'A distance' && userWorkType == 'en ligne') ||
            (projectWorkType == 'Sur site' && userWorkType == 'en presentiel');

        return title.contains(searchText.toLowerCase()) ||
            description.contains(searchText.toLowerCase()) ||
            clientName.contains(searchText.toLowerCase()) ||
            date.contains(searchText.toLowerCase()) && workTypeMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          SizedBox(width: 60),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Trouver des projets",
              ),
              onChanged: searchProjects,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Projets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          if (snapshot.hasData) {
            projects = snapshot.data!.docs;

            final List<DocumentSnapshot> displayProjects =
                filteredProjects.isNotEmpty ? filteredProjects : projects;

            return ListView.builder(
              itemCount: displayProjects.length,
              itemBuilder: (context, index) {
                final project = displayProjects[index];
                var projectData = project.data() as Map<String, dynamic>;

                String description = projectData['description'];
                String firstLine = description.split('\n')[0];

                // Formatage de la date
                DateTime dateAjout =
                    (projectData['dateAjout'] as Timestamp).toDate();
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(dateAjout);

                // Vérifiez si le champ 'statut' existe et affichez-le
                String statut = projectData['statut'] ?? "Non spécifié";

                // Définir la couleur du statut
                Color statutColor = Colors.grey; // Couleur par défaut
                if (statut == 'ouvert') {
                  statutColor = Colors.green;
                } else if (statut == 'fermé') {
                  statutColor = Colors.red;
                }

                // Vérifiez si le type de travail du projet correspond à celui de l'utilisateur
                bool showProject = userWorkType == null ||
                    (projectData['typeTravail'] == 'A distance' &&
                        userWorkType == 'en ligne') ||
                    (projectData['typeTravail'] == 'Sur site' &&
                        userWorkType == 'en presentiel');

                if (!showProject) {
                  // Ne pas afficher le projet si le type de travail ne correspond pas
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetail(
                          projectId: project.id,
                          freelanceId: widget.userId,
                        ), // Passe l'ID du projet
                      ),
                    );
                  },
                  child: ListTile(
                    leading: SizedBox(
                      width: 100,
                      child: Image.network(projectData['image']),
                    ),
                    title: Text(projectData['titre']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectData['nomClient'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(firstLine),
                        Text(
                          "Statut: $statut",
                          style: TextStyle(
                              color: statutColor), // Appliquez la couleur
                        ), // Affichez le statut
                        Text(
                          "Type de travail: ${projectData['typeTravail']}",
                          style: TextStyle(
                              color: Colors.blue), // Appliquez la couleur
                        ), // Affichez le type de travail
                      ],
                    ),
                    trailing: Text(formattedDate), // Affichez la date formatée
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
