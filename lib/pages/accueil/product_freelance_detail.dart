import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart'
    as http; // Importez la librairie http pour les requêtes HTTP
import 'dart:convert'; // Importez la librairie convert pour décoder JSON
import 'package:uuid/uuid.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetails({Key? key, required this.productData}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final List<VideoPlayerController> _videoControllers = [];
  var uuid = Uuid();

  Future<void> _makePayment() async {
    await Get.to(CinetPayCheckout(
        title: 'Abonnement',
        titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleBackgroundColor: Color.fromARGB(255, 84, 158, 228),
        configData: <String, dynamic>{
          'apikey': '72491895565f879ded8edc6.00672946',
          'site_id': int.parse("5874221"),
          'notify_url': 'https://doccam.vercel.app/notify-url'
        },
        paymentData: <String, dynamic>{
          'transaction_id': uuid.v4(), // Assurez-vous que ce champ est unique
          'amount': 1000,
          'currency': 'XAF',
          'channels': 'ALL',
          'description': "l'abonnement"
        },
        waitResponse: (response) {
          print('Response: $response');
          // Gérer la réponse ici
          if (response['status'] == 'accepted') {
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text('Payment reussie'),
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
        },
        onError: (error) {
          print('Erreur: $error');
        }));
  }

  @override
  void initState() {
    super.initState();
    // Initialiser les lecteurs vidéo
    for (String videoUrl in widget.productData['videos']) {
      _videoControllers.add(VideoPlayerController.network(videoUrl)
        ..initialize().then((value) {
          setState(() {});
        }));
    }
  }

  @override
  void dispose() {
    // Libérer les lecteurs vidéo
    for (VideoPlayerController controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.productData['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel pour les images et vidéos
            CarouselSlider.builder(
              itemCount: widget.productData['images'].length +
                  widget.productData['videos'].length,
              itemBuilder: (context, index, realIndex) {
                if (index < widget.productData['images'].length) {
                  return Image.network(
                    widget.productData['images'][index],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  // Index pour les vidéos
                  final videoIndex =
                      index - widget.productData['images'].length;
                  return FutureBuilder<void>(
                    future: _videoControllers[videoIndex.toInt()].initialize(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: (_videoControllers[videoIndex.toInt()]
                                          .value
                                          .aspectRatio *
                                      100)
                                  .toInt() /
                              100,
                          child: VideoPlayer(
                              _videoControllers[videoIndex.toInt()]),
                        );
                      } else {
                        return const CircularProgressIndicator(
                          color: Colors.blue,
                        );
                      }
                    },
                  );
                }
              },
              options: CarouselOptions(
                height: 200,
                autoPlay: false,
                enlargeCenterPage: true,
              ),
            ),
            // Description du produit
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productData['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.productData['description'],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${widget.productData['price']} FCFA',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Bouton "Acheter"
                  ElevatedButton(
                    onPressed: _makePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Acheter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
