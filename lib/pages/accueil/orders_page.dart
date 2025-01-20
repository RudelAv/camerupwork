import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/recruit_job_detail.dart';

class OrdersPage extends StatefulWidget {
  final String userId;
  const OrdersPage({
    super.key,
    // required this.openDrawer,
    required this.userId,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 onglets
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Reçues'),
            Tab(text: 'Terminées'), // Seuls 3 onglets
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PendingOrders(),
                ReceivedOrders(),
                CompletedOrders(), // 3 enfants pour TabBarView
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RecruitedProjects(
                        userId: widget.userId,
                      ),
                  fullscreenDialog: true));
            },
            child: const Text('Voir Projets Recrutés'),
          ),
        ],
      ),
    );
  }
}

class PendingOrders extends StatelessWidget {
  const PendingOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Remplacez par le nombre réel de commandes
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Commande #$index'),
            subtitle: Text('Statut: En attente'),
            trailing: ElevatedButton(
              onPressed: () {
                // Action à effectuer pour la commande
              },
              child: Text('Détails'),
            ),
          ),
        );
      },
    );
  }
}

class ReceivedOrders extends StatelessWidget {
  const ReceivedOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Commandes reçues'),
    );
  }
}

class CompletedOrders extends StatelessWidget {
  const CompletedOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Commandes terminées'),
    );
  }
}

class RecruitedProjects extends StatefulWidget {
  final String userId;
  const RecruitedProjects({Key? key, required this.userId}) : super(key: key);

  @override
  State<RecruitedProjects> createState() => _RecruitedProjectsState();
}

class _RecruitedProjectsState extends State<RecruitedProjects> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Mes Missions'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .collection('MesProjets')
            .snapshots(), // Récupérez les projets de la sous-collection 'MesProjets'
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final projects = snapshot.data!.docs;

            if (projects.isEmpty) {
              return const Center(
                child: Text('Aucun projet recruté pour le moment.'),
              );
            }

            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final projectData = project.data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.work),
                    title: Text(
                        projectData['titre']), // Affichez le titre du projet
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Statut: ${projectData['statut']}'), // Affichez le statut du projet
                        // Vous pouvez ajouter d'autres informations ici,
                        // comme la date de début, etc.
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RecruitJobDetail(
                            projectId: projectData['projectId'],
                            userId: widget.userId,
                          ),
                        ));
                      },
                      child: Text('Détails'),
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
