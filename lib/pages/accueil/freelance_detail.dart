import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/components/portfolio.dart';
import 'package:pfe/pages/accueil/freelance_market_place.dart';
import 'package:pfe/pages/chat.dart';
import 'package:pfe/pages/search_page.dart';

class FreelanceDetail extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String date;
  final String description;
  final String userId;
  final String freelanceId;

  const FreelanceDetail({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.date,
    required this.description,
    required this.userId,
    required this.freelanceId,
  });

  @override
  State<FreelanceDetail> createState() => _FreelanceDetailState();
}

class _FreelanceDetailState extends State<FreelanceDetail> {
  // Fonction pour afficher le modal de review
  void _showReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        final ratingNotifier = ValueNotifier<int>(0);
        final commentController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laisser un commentaire',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Votre commentaire...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: ratingNotifier,
                builder: (context, rating, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: () {
                            ratingNotifier.value = i;
                          },
                          icon: Icon(
                            Icons.star,
                            color: i <= rating ? Colors.yellow : Colors.grey,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Vérifiez si l'utilisateur a déjà donné un avis
                  bool hasReviewed = await _hasUserReviewed();

                  // Si l'utilisateur n'a pas encore donné d'avis
                  if (!hasReviewed) {
                    // Enregistrez l'avis dans Firebase
                    await _submitReview(
                      ratingNotifier.value,
                      commentController.text,
                    );
                    // Affiche un message de confirmation
                    _showSuccessMessage(context);
                    // Fermez le modal
                    Navigator.of(context).pop();
                  } else {
                    // Affiche un message indiquant que l'utilisateur a déjà donné un avis
                    _showErrorMessage(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Envoyer'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Fonction pour enregistrer l'avis dans Firebase
  Future<void> _submitReview(int rating, String comment) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('Avis').add({
      'userId': widget.userId,
      'freelanceId': widget.freelanceId,
      'rating': rating,
      'comment': comment,
    });
  }

  // Fonction pour vérifier si l'utilisateur a déjà donné un avis
  Future<bool> _hasUserReviewed() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('Avis')
        .where('userId', isEqualTo: widget.userId)
        .where('freelanceId', isEqualTo: widget.freelanceId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Fonction pour afficher un message de succès
  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Avis envoyé avec succès !'),
        backgroundColor: Colors.green, // Couleur verte pour le succès
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Arrondir les coins
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Fonction pour afficher un message d'erreur
  void _showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Vous avez déjà donné un avis'),
        backgroundColor: Colors.red, // Couleur rouge pour l'erreur
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Arrondir les coins
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Fonction pour afficher le modal de description complète
  void _showFullDescriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description.split('\n').first,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.description.split('\n').length > 1)
                        Text(
                          widget.description.split('\n').skip(1).join('\n'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToMarketPlace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FreelanceMarketPlace(
          userId: widget.userId,
          freelanceId: widget.freelanceId,
          freelanceName: widget.name,
        ),
      ),
    );
  }

  void _showFullPortfolioModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Portfolio')
              .doc(widget.freelanceId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Erreur : ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final portfolioData =
                snapshot.data?.data() as Map<String, dynamic>?;
            final items = portfolioData?['items'] as List?;

            if (items != null && items.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Portfolio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          if (items[index]['type'] == 'image') {
                            return Image.network(items[index]['url']);
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text('Aucun élément dans le portfolio'),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('A propos de moi'),
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: BackButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => SearchPage(
        //           userId: widget.userId,
        //         ),
        //       ),
        //     );
        //   },
        // ),
        actions: [
          // Affiche l'icône de commentaire uniquement si l'utilisateur n'a pas encore donné d'avis
          FutureBuilder<bool>(
            future: _hasUserReviewed(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!) {
                  return Container(); // Cache l'icône si l'utilisateur a déjà donné un avis
                } else {
                  return IconButton(
                    onPressed: () {
                      _showReviewModal(context);
                    },
                    icon: const Icon(Icons.comment),
                  );
                }
              } else {
                return const CircularProgressIndicator(
                  color: Colors.blue,
                ); // Affiche un indicateur de chargement pendant la vérification
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Affichage de l'image du freelance
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Portfolio')
                    .doc(widget.freelanceId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final portfolioData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final items = portfolioData?['items'] as List?;

                  if (items != null && items.isNotEmpty) {
                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: items.map((item) {
                        if (item['type'] == 'image') {
                          return Image.network(item['url']);
                        } else {
                          return Container();
                        }
                      }).toList(),
                    );
                  } else {
                    return SizedBox(
                        height: 200); // Espace vide si pas de portfolio
                  }
                },
              ),
              const SizedBox(height: 16.0),
              // Affichage des détails du freelance
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundImage: Image.network(widget.imageUrl).image,
                      radius: 30.0,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        // Affichage de la note et de la moyenne des étoiles
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Avis')
                              .where('freelanceId',
                                  isEqualTo: widget.freelanceId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Erreur : ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            // Calculer la moyenne des étoiles
                            double averageRating = 0.0;
                            if (snapshot.data!.docs.isNotEmpty) {
                              averageRating = snapshot.data!.docs
                                      .map((doc) => doc['rating'] as int)
                                      .reduce(
                                          (value, element) => value + element) /
                                  snapshot.data!.docs.length;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16.0,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      averageRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Affichage des détails
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Date et description
                    GestureDetector(
                      onTap: () {
                        _showFullDescriptionModal(context);
                      },
                      child: Container(
                        // Définir la hauteur en fonction de l'état
                        height: 60, // Hauteur réduite
                        child: Text(
                          widget.description
                              .split('\n') // Séparez la description en lignes
                              .take(2) // Prendre les deux premières lignes
                              .join(
                                  '\n'), // Remettez les lignes ensemble avec un retour à la ligne
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              // Affichage des commentaires
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Avis')
                    .where('freelanceId', isEqualTo: widget.freelanceId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  // Affichage des commentaires dans le carousel
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final commentData = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return SizedBox(
                          width: 250,
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            color: Colors.white, // Définir la couleur du Card
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Récupérer le nom de l'utilisateur qui a posté l'avis
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(commentData['userId'])
                                        .get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasData) {
                                        final userData = userSnapshot.data!
                                            .data() as Map<String, dynamic>;
                                        return Text(
                                          userData['username'] ?? 'Utilisateur',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      } else if (userSnapshot.hasError) {
                                        return Text(
                                            'Erreur : ${userSnapshot.error}');
                                      }
                                      return CircularProgressIndicator();
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  Text(commentData['comment']),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      for (int i = 1;
                                          i <= commentData['rating'];
                                          i++)
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16.0,
                                        ),
                                      for (int i = commentData['rating'] + 1;
                                          i <= 5;
                                          i++)
                                        Icon(
                                          Icons.star,
                                          color: Colors.grey,
                                          size: 16.0,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              // Affichage des boutons
              const SizedBox(
                height: 16.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mon portfolio',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showFullPortfolioModal(context);
                          },
                          child: const Text('Tout afficher'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Portfolio')
                            .doc(widget.freelanceId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Erreur : ${snapshot.error}');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          final portfolioData =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          final items = portfolioData?['items'] as List?;

                          if (items != null && items.isNotEmpty) {
                            // Affiche 4 images maximum
                            int maxImages = 4;
                            if (items.length < maxImages) {
                              maxImages = items.length;
                            }
                            return SizedBox(
                              height: 200,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemCount: maxImages,
                                itemBuilder: (context, index) {
                                  if (items[index]['type'] == 'image') {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(items[index]['url']),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            );
                          } else {
                            return const SizedBox(
                                height: 200); // Espace vide si pas de portfolio
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Affiche le nombre d'images restantes
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Portfolio')
                    .doc(widget.freelanceId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final portfolioData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final items = portfolioData?['items'] as List?;

                  if (items != null && items.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '${items.length - 4} ${items.length - 4 > 1 ? 'images' : 'image'} restantes',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToMarketPlace(context);
                },
                child: const Text("Market Place"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                freelanceName: widget.name,
                userProfileImage: widget.imageUrl,
                userId: widget.userId,
                freelanceId: widget.freelanceId,
              ),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.message),
      ),
    );
  }
}
