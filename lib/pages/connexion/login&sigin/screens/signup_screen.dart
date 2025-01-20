// import 'dart:js_interop';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pfe/logos.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart';
// import 'package:pfe/pages/accueil/index.dart';
import 'package:pfe/pages/connexion/creation_profil/categorie_activite.dart';
// import 'package:pfe/pages/connexion/creation_profil/creation_profil.dart';
import 'package:pfe/pages/connexion/login&sigin/screens/signin_screen.dart';
import 'package:pfe/pages/connexion/login&sigin/theme/theme.dart';
import 'package:pfe/pages/connexion/login&sigin/widgets/custom_scaffold.dart';
import 'package:pfe/services/auth_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  final AuthService _auth = AuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Variable pour stocker le token de notification
  String? _notificationToken;

  // Variable pour contrôler l'affichage du CircularProgressIndicator
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialiser le service de notification
    _initNotification();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Demarrer',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Nom d\'utilisateur'),
                          hintText: 'Nom d\'utilisateur',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Entez l\'Email'),
                          hintText: 'Entez l\'Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Mot de passe'),
                          hintText: 'Mot de passe',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              // Afficher le CircularProgressIndicator
                              setState(() {
                                _isLoading = true;
                              });

                              _signUp();
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please agree to the processing of personal data')),
                              );
                            }
                          },
                          child: const Text('Creer mon compte'),
                        ),
                      ),
                      // Afficher le CircularProgressIndicator si _isLoading est true
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue, // Couleur bleue
                          ),
                        ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Se Connecter avec',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up social media logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Icon(
                              Icons.facebook,
                              color: Colors.blue,
                              size: 32.0,
                            ),
                            onTap: () {
                              AuthService().signInWithFacebook().then((user) {
                                // La connexion a réussi, rediriger l'utilisateur vers index.dart
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyHomePage(
                                      userId: '',
                                    ),
                                  ),
                                );
                              }).catchError((error) {
                                // Gérer les erreurs de connexion
                                print('Erreur de connexion Facebook: $error');
                              });
                            },
                          ),
                          Logo(Logos.twitter),
                          InkWell(
                            child: Icon(
                              FontAwesomeIcons.google,
                              color: Color.fromRGBO(255, 0, 0, 1.0),
                              size: 32.0,
                            ),
                            onTap: () {
                              AuthService()
                                  .signInWithGoogle()
                                  .then((userCredential) {
                                if (userCredential != null) {
                                  // Récupérer les informations de l'utilisateur
                                  String userId = userCredential.user!.uid;
                                  String username =
                                      userCredential.user!.displayName ?? '';
                                  String email =
                                      userCredential.user!.email ?? '';

                                  // Enregistrer les informations de l'utilisateur dans la collection "Users"
                                  FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(userId)
                                      .set({
                                    'id_user': userId,
                                    'username': username,
                                    'email': email,
                                    'notificationToken':
                                        _notificationToken, // Ajouter le token
                                  }).then((_) {
                                    // Rediriger l'utilisateur vers CategorieActivite avec les informations récupérées
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategorieActivite(
                                          userId: userId,
                                          username: username,
                                          email: email,
                                        ),
                                      ),
                                    );
                                  }).catchError((error) {
                                    // Gérer les erreurs d'enregistrement
                                    print(
                                        'Erreur lors de l\'enregistrement des informations de l\'utilisateur: $error');
                                  });
                                }
                              }).catchError((error) {
                                // Gérer les erreurs de connexion
                                print('Erreur de connexion Google: $error');
                              });
                            },
                          ),
                          Logo(Logos.apple),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Vous avez deja un compte? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initNotification() async {
    // Demander la permission pour les notifications
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Vérifier si la permission est accordée
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Obtenir le token de notification
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _notificationToken = token;
      });
      print("Token de notification: $_notificationToken");
    }
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Créer l'utilisateur dans Firebase Auth
      User? user =
          await AuthService().signUpWithEmailAndPassword(email, password);

      if (user != null) {
        String userId = user.uid;

        // Enregistrer les données de l'utilisateur dans Firestore, y compris le token de notification
        await FirebaseFirestore.instance.collection('Users').doc(userId).set({
          'id_user': userId,
          'username': username,
          'email': email,
          'createdAt': Timestamp.now(),
          'notificationToken': _notificationToken, // Ajouter le token
        });

        print("Utilisateur créé avec succès");
        // Masquer le CircularProgressIndicator après la création de l'utilisateur
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategorieActivite(
                    username: username,
                    email: email,
                    userId: userId,
                  )),
        );
      } else {
        print("Une erreur est survenue lors de la création de l'utilisateur");
        // Masquer le CircularProgressIndicator après l'erreur
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la création de l'utilisateur: $e");
      // Masquer le CircularProgressIndicator après l'erreur
      setState(() {
        _isLoading = false;
      });
    }
  }
}
