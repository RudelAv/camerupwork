import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:pfe/pages/accueil/freelance_detail.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChatPage extends StatefulWidget {
  final String freelanceName;
  final String userProfileImage;
  final String userId;
  final String freelanceId;

  ChatPage({
    required this.freelanceName,
    required this.userProfileImage,
    required this.userId,
    required this.freelanceId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? conversationId;
  List<Map<String, dynamic>> _messages = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchConversationId();
  }

  Future<void> _fetchConversationId() async {
    // Récupérer ou créer l'ID de conversation
    final conversationRef = FirebaseFirestore.instance
        .collection('Conversations')
        .doc(getConversationId(widget.userId, widget.freelanceId));
    final conversationDoc = await conversationRef.get();

    if (conversationDoc.exists) {
      conversationId = conversationDoc.id;
    } else {
      await conversationRef.set({
        'participants': [widget.userId, widget.freelanceId],
      });
      conversationId = conversationRef.id;
    }
    _fetchMessages();
  }

  String getConversationId(String userId1, String userId2) {
    // Fonction pour générer un ID de conversation unique
    List<String> sortedIds = [userId1, userId2];
    sortedIds.sort(); // Sort the list in place
    return sortedIds.join('_');
  }

  void _fetchMessages() async {
    if (conversationId != null) {
      final messagesStream = FirebaseFirestore.instance
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .orderBy('timestamp', descending: true)
          .snapshots();

      messagesStream.listen((snapshot) {
        setState(() {
          _messages = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty || _selectedImage != null) {
      final messageData = {
        'senderId': widget.userId,
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
        'image':
            _selectedImage != null ? await _uploadImage(_selectedImage!) : null,
      };

      await FirebaseFirestore.instance
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .add(messageData);

      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _selectedImage = null;
    }
  }

  Future<String?> _uploadImage(File image) async {
    if (image == null) return null;

    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = ref.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF17203A),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Vous discutez avec: ${widget.freelanceName}\n',
                style: const TextStyle(color: Colors.white),
              ),
              const TextSpan(
                text: 'Statut: En ligne',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: conversationId != null
                  ? FirebaseFirestore.instance
                      .collection('Conversations')
                      .doc(conversationId)
                      .collection('Messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }

                final messages = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['senderId'] == widget.userId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isCurrentUser)
                            Flexible(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                    bottomLeft: Radius.circular(16.0),
                                    bottomRight: Radius.zero,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message['image'] != null)
                                      Image.network(message['image']),
                                    if (message['message'] != null)
                                      Text(
                                        message['message'],
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (isCurrentUser)
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                    bottomLeft: Radius.zero,
                                    bottomRight: Radius.circular(16.0),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (message['image'] != null)
                                      Image.network(message['image']),
                                    if (message['message'] != null)
                                      Text(
                                        message['message'],
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
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
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    _showImagePickerModal();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Select from gallery'),
              onTap: () {
                _getImageFromGallery();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () {
                _getImageFromCamera();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
}
