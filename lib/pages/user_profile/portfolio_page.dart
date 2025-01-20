// import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class PortfolioPage extends StatefulWidget {
  final String userId; // Add userId parameter

  const PortfolioPage({super.key, required this.userId});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<PortfolioItem> portfolioItems = [];
  final ImagePicker _picker = ImagePicker();
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer votre Portfolio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: portfolioItems.length,
                  itemBuilder: (context, index) {
                    final item = portfolioItems[index];
                    return Dismissible(
                      key: Key(item.id),
                      onDismissed: (direction) {
                        setState(() {
                          portfolioItems.removeAt(index);
                        });
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isEditing = true;
                            item.isEditing = true;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Affichage de l'image ou de la vidéo sélectionnée
                              if (item.isImage && item.imageUrl != null)
                                Image.network(item.imageUrl!,
                                    height: 200, width: 200, fit: BoxFit.cover)
                              else if (item.isVideo && item.videoUrl != null)
                                _buildVideoPlayer(item.videoUrl!)
                              // Affichage des icônes d'image et de vidéo si aucune sélection
                              else if (isEditing && item.isEditing)
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _selectImage(index);
                                      },
                                      icon: const Icon(Icons.image),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _selectVideo(index);
                                      },
                                      icon: const Icon(Icons.videocam),
                                    ),
                                  ],
                                ),

                              if (isEditing && item.isEditing)
                                TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      item.description = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Description',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    portfolioItems
                        .add(PortfolioItem(id: DateTime.now().toString()));
                    isEditing = true;
                  });
                },
                child: const Text('Ajouter un élément'),
              ),
              SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _savePortfolioToFirestore();
                  }
                },
                child: const Text('Soumettre'),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Charger l'image en dehors de setState()
      _loadImage(image).then((imageData) {
        setState(() {
          portfolioItems[index].isImage = true;
          // Enregistrer l'image dans Firebase Storage
          _uploadImage(imageData, index).then((imageUrl) {
            setState(() {
              portfolioItems[index].imageUrl = imageUrl;
            });
          });
          portfolioItems[index].isEditing = false;
          isEditing = false;
        });
      });
    }
  }

  Future<Uint8List> _loadImage(XFile image) async {
    return await image.readAsBytes();
  }

  Future<void> _selectVideo(int index) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      // Charger la vidéo en dehors de setState()
      _loadVideo(video).then((videoData) {
        setState(() {
          portfolioItems[index].isVideo = true;
          // Enregistrer la vidéo dans Firebase Storage
          _uploadVideo(videoData, index).then((videoUrl) {
            setState(() {
              portfolioItems[index].videoUrl = videoUrl;
            });
          });
          portfolioItems[index].isEditing = false;
          isEditing = false;
        });
      });
    }
  }

  Future<Uint8List> _loadVideo(XFile video) async {
    return await video.readAsBytes();
  }

  Future<String> _uploadImage(Uint8List imageData, int index) async {
    // Générer un nom de fichier unique
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    // Créer une référence à l'emplacement de stockage
    final Reference ref =
        _storage.ref().child('portfolio').child(widget.userId).child(fileName);
    // Enregistrer l'image dans Storage
    final UploadTask uploadTask = ref.putData(imageData);
    // Attendre la fin du téléchargement
    final TaskSnapshot snapshot = await uploadTask;
    // Obtenir l'URL de l'image
    final String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<String> _uploadVideo(Uint8List videoData, int index) async {
    // Générer un nom de fichier unique
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    // Créer une référence à l'emplacement de stockage
    final Reference ref =
        _storage.ref().child('portfolio').child(widget.userId).child(fileName);
    // Enregistrer la vidéo dans Storage
    final UploadTask uploadTask = ref.putData(videoData);
    // Attendre la fin du téléchargement
    final TaskSnapshot snapshot = await uploadTask;
    // Obtenir l'URL de la vidéo
    final String videoUrl = await snapshot.ref.getDownloadURL();
    return videoUrl;
  }

  Widget _buildVideoPlayer(String videoUrl) {
    final videoController = VideoPlayerController.network(videoUrl);
    return FutureBuilder(
      future: videoController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> _savePortfolioToFirestore() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final portfolioData = portfolioItems.map((item) {
      return {
        'type': item.isImage ? 'image' : 'video',
        'url': item.isImage ? item.imageUrl : item.videoUrl,
        'description': item.description,
      };
    }).toList();

    await db.collection('Portfolio').doc(widget.userId).set({
      'userId': widget.userId,
      'items': portfolioData,
    }).then((value) {
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Portfolio enregistré avec succès !')),
      );
    }).catchError((error) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement : $error')),
      );
    });
  }
}

class PortfolioItem {
  String id;
  bool isImage = false;
  bool isVideo = false;
  String? imageUrl;
  String? videoUrl;
  String? description;
  bool isEditing = false;

  PortfolioItem({required this.id});
}
