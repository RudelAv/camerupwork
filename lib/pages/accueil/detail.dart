import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/components/portfolio.dart';
import 'package:pfe/pages/accueil/index.dart';
import 'package:pfe/pages/chat.dart';

class DetailPage extends StatelessWidget {
  final String imageUrl;
  final String freelanceName;
  final String date;
  final String description;

  const DetailPage({
    required this.imageUrl,
    required this.freelanceName,
    required this.date,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // var rating;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IndexPage(
                  userId: '',
                ),
              ),
            );
          },
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: [
                    Image.asset(imageUrl),
                    // Image.asset(imageUrl2), // Ajoutez d'autres images ici
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 16.0),
                      child: CircleAvatar(
                        backgroundImage: AssetImage("lib/assets/th3.jpg"),
                        radius: 30.0,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            freelanceName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16.0,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                3.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date),
                      SizedBox(height: 8),
                      Text(description),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 300.0,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 4),
                      autoPlayAnimationDuration: Duration(milliseconds: 700),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: [
                      Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(26, 37, 36, 36)),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage("lib/assets/google.png"),
                            ),
                            Text(
                              freelanceName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(date),
                            SizedBox(height: 8),
                            Text(description),
                            SizedBox(height: 16),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16.0,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              3.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PortfolioPage(),
                        ),
                      );
                    },
                    child: Text("Portfolio"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                freelanceName: freelanceName,
                userProfileImage: imageUrl,
                userId: '',
                freelanceId: '',
              ),
            ),
          );
        },
        backgroundColor: Colors.blue, // Couleur bleue
        child: Icon(Icons.message),
      ),
    );
  }
}
