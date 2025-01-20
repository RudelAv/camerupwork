import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key});

  @override
  State<EmailAuth> createState() => _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
        title: const Center(
          child: Text("Verified Email"),
        ),
      ),
      body: ListView(children: [
        FirebaseAuth.instance.currentUser!.emailVerified
            ? MyHomePage(
                userId: '',
              )
            : MaterialButton(
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  FirebaseAuth.instance.currentUser!.sendEmailVerification();
                },
                child: const Text("Please Check Your Email"),
              )
      ]),
    );
  }
}
