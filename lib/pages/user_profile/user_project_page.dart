import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pfe/pages/connexion/creation_profil/job_detail.dart'; // Importez la bibliothèque intl
import 'package:pfe/pages/user_profile/CandidatesList.dart';
import 'package:pfe/widget/drawer_menu_widget.dart';

class UserProjectsPage extends StatefulWidget {
  final VoidCallback openDrawer;
  final String userId;
  const UserProjectsPage({
    super.key,
    required this.openDrawer,
    required this.userId,
  });

  @override
  State<UserProjectsPage> createState() => _UserProjectsPageState();
}

class _UserProjectsPageState extends State<UserProjectsPage> {
  void _showCandidates(String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatesList(
          projectId: projectId,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text("Mes Projets")),
        leading: DrawerMenuWidget(
          onClicked: widget.openDrawer,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Projets')
            .where('id_user', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          if (snapshot.hasData) {
            final projects = snapshot.data!.docs;

            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                var projectData = project.data() as Map<String, dynamic>;

                String description = projectData['description'];
                String firstLine = description.split('\n')[0];

                // Formatage de la date
                DateTime dateAjout =
                    (projectData['dateAjout'] as Timestamp).toDate();
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(dateAjout);

                return Card(
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
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showCandidates(project.id);
                          },
                          child: const Text(
                            "Candidats",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        // Ajoutez le bouton "Fermer" ici
                        if (projectData['statut'] == 'ouvert')
                          ElevatedButton(
                            onPressed: () {
                              // Mettre à jour le statut du projet à "fermé"
                              FirebaseFirestore.instance
                                  .collection('Projets')
                                  .doc(project.id)
                                  .update({'statut': 'fermé'});
                            },
                            child: Text('Fermer'),
                          )
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetail(
                              projectId: project.id,
                              freelanceId: widget
                                  .userId), // Passez l'ID du projet et l'ID du freelance
                        ),
                      );
                    },
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
