import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/demarrage.dart';
// import 'package:pfe/pages/connexion/login&sigin/screens/welcome_screen.dart';
// import 'package:pfe/pages/connexion/Login.dart';
// import 'package:pfe/pages/connexion/accueil.dart';
import 'package:pfe/pages/connexion/login&sigin/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true, 
    announcement: true, 
    badge: true, 
    carPlay: false, 
    provisional:
        false, 
    sound: true, 
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Notification permission granted.');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('Notification permission granted provisionally.');
  } else {
    print('Notification permission denied.');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Message reçu en arrière-plan : ${message.messageId}');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: SplashScreen(),
      // home: LoginPage(),
    );
  }
}
