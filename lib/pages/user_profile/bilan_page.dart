import 'package:flutter/material.dart';

class BilanPage extends StatelessWidget {
  const BilanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Mon Bilan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [],
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 18,
            ),
            Center(
              child: Text(
                'Solde sur CamerUpWork',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              color: Color.fromARGB(255, 248, 247, 247),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // Bords arrondis
              ),
              margin:
                  EdgeInsets.symmetric(horizontal: 16.0), // Marge horizontale
              child: SizedBox(
                height: 100,
                child: Padding(
                  padding:
                      EdgeInsets.all(16.0), // Padding à l'intérieur de la carte
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Center(
                            child: Text(
                              '10 000 XAF',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold // Couleur rouge
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Center(
              child: Text(
                'Depots sur CamerUpWork',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              color: Color.fromARGB(255, 248, 247, 247),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // Bords arrondis
              ),
              margin:
                  EdgeInsets.symmetric(horizontal: 16.0), // Marge horizontale
              child: SizedBox(
                height: 100,
                child: Padding(
                  padding:
                      EdgeInsets.all(16.0), // Padding à l'intérieur de la carte
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Center(
                            child: Text(
                              '10 000 XAF',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold // Couleur rouge
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
