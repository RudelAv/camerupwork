import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Importez la bibliothèque image_picker
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String userId;
  const ConversationPage(
      {Key? key, required this.conversationId, required this.userId})
      : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker(); // Instance de ImagePicker

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFile(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      throw 'Impossible d\'ouvrir le fichier.';
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final timestamp = Timestamp.now();
      final messageData = {
        'message': _messageController.text.trim(),
        'senderId': widget.userId,
        'timestamp': timestamp,
        'image': null, // Ajoutez 'image' ici si nécessaire
      };

      await FirebaseFirestore.instance
          .collection('ConversationsProjet')
          .doc(widget.conversationId)
          .collection('Messages')
          .add(messageData);

      _messageController.clear(); // Effacez le champ de saisie

      // Faites défiler jusqu'au dernier message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Fonction pour choisir une image de la galerie ou de la caméra
  Future<void> _chooseImage() async {
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource
          .gallery, // Utilisez ImageSource.gallery pour la galerie ou ImageSource.camera pour la caméra
    );

    if (imageFile != null) {
      _uploadImage(imageFile); // Envoyez l'image à Firebase Storage
    }
  }

  Future<void> _uploadImage(XFile imageFile) async {
    final storageRef = FirebaseStorage.instance.ref().child('images').child(
        '${DateTime.now().millisecondsSinceEpoch}.jpg'); // Chemin unique pour l'image

    try {
      final bytes = await imageFile
          .readAsBytes(); // Lire l'image en tant que tableau d'octets

      // Enregistrez le tableau d'octets dans un fichier temporaire
      final tempDir =
          await getTemporaryDirectory(); // Appelle la méthode getTemporaryDirectory
      final tempFile =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);

      final uploadTask = storageRef.putFile(tempFile); // Téléchargez l'image
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref
          .getDownloadURL(); // Obtenez l'URL de téléchargement

      // Enregistrez l'URL dans Firestore
      await FirebaseFirestore.instance
          .collection('ConversationsProjet')
          .doc(widget.conversationId)
          .collection('Messages')
          .add({
        'message': '', // Vous pouvez ajouter un message ici si nécessaire
        'senderId': widget.userId,
        'timestamp': Timestamp.now(),
        'image': downloadUrl, // Enregistrez l'URL de l'image dans Firestore
      });

      // Faites défiler jusqu'au dernier message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Permet de choisir n'importe quel type de fichier
    );

    if (result != null) {
      _uploadFile(result.files.first.path!); // Utilisez l'opérateur !
    }
  }

  // Fonction pour télécharger un fichier vers Firebase Storage
  Future<void> _uploadFile(String filePath) async {
    final storageRef = FirebaseStorage.instance.ref().child('files').child(
        '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}'); // Chemin unique pour le fichier

    try {
      final file =
          File(filePath); // Créer un objet File à partir du chemin du fichier
      final uploadTask = storageRef.putFile(file); // Téléchargez le fichier
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref
          .getDownloadURL(); // Obtenez l'URL de téléchargement

      // Enregistrez l'URL dans Firestore
      await FirebaseFirestore.instance
          .collection('ConversationsProjet')
          .doc(widget.conversationId)
          .collection('Messages')
          .add({
        'message': '', // Vous pouvez ajouter un message ici si nécessaire
        'senderId': widget.userId,
        'timestamp': Timestamp.now(),
        'file': downloadUrl, // Enregistrez l'URL du fichier dans Firestore
      });

      // Faites défiler jusqu'au dernier message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversation"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ConversationsProjet')
                  .doc(widget.conversationId)
                  .collection('Messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData =
                          messages[index].data() as Map<String, dynamic>;
                      final senderId = messageData['senderId'];
                      final isCurrentUser = senderId == widget.userId;
                      final imageUrl =
                          messageData['image']; // Récupérez l'URL de l'image
                      final fileUrl = messageData['file'];

                      return Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isCurrentUser)
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(senderId)
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                  }

                                  if (userSnapshot.hasData) {
                                    final userData = userSnapshot.data!.data()
                                        as Map<String, dynamic>;
                                    return CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          userData['photoProfil'] ?? ''),
                                      radius: 20,
                                    );
                                  }

                                  return const SizedBox();
                                },
                              ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.blue
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (messageData['message'] != null)
                                    Text(
                                      messageData['message'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isCurrentUser
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:mm').format(
                                      (messageData['timestamp'] as Timestamp)
                                          .toDate(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  if (imageUrl !=
                                      null) // Affichez l'image si elle existe
                                    SizedBox(height: 8),
                                  if (imageUrl != null)
                                    Image.network(
                                      imageUrl,
                                      height:
                                          200, // Définissez une hauteur appropriée
                                      width:
                                          200, // Définissez une largeur appropriée
                                      fit: BoxFit.cover,
                                    ),
                                  if (fileUrl != null)
                                    GestureDetector(
                                      onTap: () => _openFile(fileUrl),
                                      child: Text(
                                        fileUrl.split('/').last,
                                        style: TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ],
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
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                  color: Colors.blue,
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _chooseImage,
                  icon: Icon(Icons.image),
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: _chooseFile,
                  icon: Icon(Icons.attach_file),
                  color: Colors.blue,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
