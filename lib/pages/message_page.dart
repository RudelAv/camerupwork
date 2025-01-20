import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/chat.dart';
// import 'package:pfe/pages/chat_page.dart';
// import 'package:pfe/widget/drawer_menu_widget.dart';

class MessagePage extends StatefulWidget {
  // final VoidCallback openDrawer;
  final String userId;
  const MessagePage({
    super.key,
    // required this.openDrawer,
    required this.userId,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF17203A),
        // leading: DrawerMenuWidget(
        //   onClicked: widget.openDrawer,
        // ),
        // title: const Text('message Page'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFF17203A)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: ('Quicksand'),
                        fontSize: 30,
                        color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 36,
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('Conversations')
                    .where('participants', arrayContains: widget.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune conversation trouvée',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final conversation = snapshot.data!.docs[index];
                      final otherUserId = conversation['participants']
                          .where((id) => id != widget.userId)
                          .single;

                      return FutureBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        future: _firestore
                            .collection('Users')
                            .doc(otherUserId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasError) {
                            return Text('Error: ${userSnapshot.error}');
                          }

                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          // Check if a user document was found
                          if (!userSnapshot.hasData ||
                              userSnapshot.data!.data() == null) {
                            return Text("User not found");
                          }

                          final otherUser = userSnapshot.data!.data()!;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      freelanceName: otherUser['username'],
                                      userProfileImage: otherUser['imageUrl'] ??
                                          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/User_icon_2.svg/1200px-User_icon_2.svg.png',
                                      userId: widget.userId,
                                      freelanceId: otherUser['id_user'],
                                    ),
                                  ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 26.0, top: 35, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                          otherUser['imageUrl'] ??
                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/User_icon_2.svg/1200px-User_icon_2.svg.png',
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            otherUser['username'] ?? '',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: ('Quicksand'),
                                                fontSize: 17),
                                          ),
                                          //  Afficher le dernier message ici
                                          FutureBuilder<
                                              QuerySnapshot<
                                                  Map<String, dynamic>>>(
                                            future: _firestore
                                                .collection('Conversations')
                                                .doc(conversation.id)
                                                .collection('Messages')
                                                .orderBy('timestamp',
                                                    descending: true)
                                                .limit(1) // Limiter à 1 message
                                                .get(),
                                            builder:
                                                (context, messageSnapshot) {
                                              if (messageSnapshot.hasError) {
                                                return Text(
                                                    'Error: ${messageSnapshot.error}');
                                              }

                                              if (messageSnapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }

                                              if (messageSnapshot
                                                  .data!.docs.isEmpty) {
                                                return SizedBox
                                                    .shrink(); // Vide
                                              }

                                              final lastMessage =
                                                  messageSnapshot
                                                      .data!.docs.first
                                                      .data()!;
                                              return Text(
                                                lastMessage['message'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: ('Quicksand'),
                                                  fontSize:
                                                      13, // Police plus petite
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
