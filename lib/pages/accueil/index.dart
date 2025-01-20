import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pfe/assistant/home_screen_assistant.dart';
import 'package:pfe/data/drawer_items.dart';
import 'package:pfe/models/drawer_item.dart';
import 'package:pfe/pages/accueil/activite_widget.dart';
import 'package:pfe/pages/accueil/post_widget.dart';
import 'package:pfe/pages/accueil/search_work.dart';
import 'package:pfe/pages/add_job_page.dart';
import 'package:pfe/pages/favorite_page.dart';
import 'package:pfe/pages/user_profile/user_project_page.dart';
import 'package:pfe/widget/drawer_menu_widget.dart';
import 'package:pfe/widget/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importez la bibliothèque Firestore

class IndexPage extends StatelessWidget {
  final String userId;
  const IndexPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(
        userId: userId,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final String userId;
  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late double xOffset;
  late double yOffset;
  late double scaleFactor;
  late bool isDrawerOpen;
  bool isDragging = false;
  DrawerItem item = DrawerItems.home;

  @override
  void initState() {
    super.initState();

    closeDrawer();
  }

  void openDrawer() => setState(() {
        xOffset = 230;
        yOffset = 150;
        scaleFactor = 0.6;
        isDrawerOpen = true;
      });

  void closeDrawer() => setState(() {
        xOffset = 0;
        yOffset = 0;
        scaleFactor = 1;
        isDrawerOpen = false;
      });
  @override
  Widget build(BuildContext context) => Scaffold(
      // backgroundColor: Color.fromRGBO(21, 30, 61, 1),
      backgroundColor: Color(0xFF17203A),
      body: Stack(
        children: [
          buildDrawer(),
          buildPage(),
        ],
      ));

  Widget buildDrawer() => SafeArea(
        child: DrawerWidget(
          onSelectedItem: (item) {
            setState(() => this.item = item);
            closeDrawer();
          },
        ),
      );

  Widget buildPage() {
    return WillPopScope(
      onWillPop: () async {
        if (isDrawerOpen) {
          closeDrawer();
          return false;
        } else {
          return true;
        }
      },
      child: GestureDetector(
        onTap: closeDrawer,
        onHorizontalDragStart: (details) => isDragging = true,
        onHorizontalDragUpdate: (details) {
          if (!isDragging) return;

          const delta = 1;
          if (details.delta.dx > delta) {
            openDrawer();
          } else if (details.delta.dx < -delta) {
            closeDrawer();
          }
        },
        child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            transform: Matrix4.translationValues(xOffset, yOffset, 0)
              ..scale(scaleFactor),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDrawerOpen ? 20 : 0),
              child: getDrawerPage(),
            )),
      ),
    );
  }

  Widget getDrawerPage() {
    switch (item) {
      // case DrawerItems.message:
      //   return MessagePage(openDrawer: openDrawer);
      case DrawerItems.settings:
        return FavoritePage(openDrawer: openDrawer);
      case DrawerItems.jobs:
        return AddJobPage(
          openDrawer: openDrawer,
          userId: widget.userId,
        );
      case DrawerItems.userjobs:
        return UserProjectsPage(
          openDrawer: openDrawer,
          userId: widget.userId,
        );
      case DrawerItems.home:
      default:
        return HomePage(openDrawer: openDrawer, userId: widget.userId);
    }
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback openDrawer;
  final String userId;
  const HomePage({
    Key? key,
    required this.openDrawer,
    required this.userId,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showSearchBar =
      true; // Variable pour contrôler l'affichage de la barre de recherche

  @override
  void initState() {
    super.initState();
    _checkUserProfil();
  }

  Future<void> _checkUserProfil() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists && userDoc.get('typeTravail') == null) {
        setState(() {
          showSearchBar = true;
        });
      } else {
        setState(() {
          showSearchBar = false;
        });
      }
    } catch (e) {
      print("Error checking user profile: $e");
      setState(() {
        showSearchBar =
            true; // Par défaut, affichez la barre de recherche en cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: DrawerMenuWidget(
            onClicked: widget.openDrawer,
          ),
          // backgroundColor: Colors.blue[200],
          title: Text(
            "CamerUpWork",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          actions: [],
        ),
        body: Center(
            child: Container(
          decoration:
              BoxDecoration(color: const Color.fromRGBO(255, 255, 255, 1)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("lib/assets/log.jpeg"),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => SearchWork(
                                        userId: widget.userId,
                                      ),
                                  fullscreenDialog: true),
                            );
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: "Trouver des projets",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Bords arrondis
                            ),
                            filled: true,
                            // fillColor: Colors.grey[300],
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ActivityWidget(userId: widget.userId),

                SizedBox(height: 16),
                // Replace with your post widgets
                // Example:
                Container(
                  height: 300, // Définissez une hauteur appropriée
                  width: double.infinity, // Définissez une largeur appropriée
                  child: PostWidget(),
                ),

                // Add more PostWidget instances as needed
                SizedBox(
                  height: 12,
                ),
                Text(
                  "Plus Populaires ce mois ci",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostWidget(),
                        ),
                      );
                    },
                    child: Text(
                      "Voir Plus",
                      style: TextStyle(color: Colors.blue),
                    )),
                const PopularPost(),
              ],
            ),
          ),
        )));
  }
}

class PopularPost extends StatelessWidget {
  const PopularPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          height: 300.0,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 700),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items: [
          Container(
            padding: EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(image: AssetImage("lib/assets/th.jpg")),
                Text(
                  "Creation de logos",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(image: AssetImage("lib/assets/tВlВcharger.jpg")),
                Text(
                  "GDeveloppement d'applications",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(image: AssetImage("lib/assets/th2.jpg")),
                Text(
                  "Graphic Design",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(image: AssetImage("lib/assets/th3.jpg")),
                Text(
                  "Copy Writting",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
