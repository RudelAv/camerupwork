import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pfe/logos.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart';
// import 'package:pfe/pages/accueil/index.dart';
import 'package:pfe/pages/connexion/login&sigin/custom_dialog_success_widget.dart';
import 'package:pfe/pages/connexion/login&sigin/custom_dialog_widget.dart';
import 'package:pfe/pages/connexion/login&sigin/screens/signup_screen.dart';
import 'package:pfe/pages/connexion/login&sigin/theme/theme.dart';
import 'package:pfe/pages/connexion/login&sigin/widgets/custom_scaffold.dart';
import 'package:pfe/services/auth_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  final AuthService _auth = AuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
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
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Bienvenue',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Entrez l\'Email',
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
                          label: const Text('Password'),
                          hintText: 'Mot de Passe',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Se souvenir de moi',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Text(
                              'Mot de passe oublie?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignInKey.currentState!.validate() &&
                                rememberPassword) {
                              _signIn();
                              // if (success) {
                              //   showDialog(
                              //       context: context,
                              //       builder: (BuildContext context) {
                              //         return CustomDialogSuccessWidget(userId: user!.uid,);
                              //       });
                              // } else {
                              //   showDialog(
                              //       context: context,
                              //       builder: (BuildContext context) {
                              //         return const CustomDialogWidget();
                              //       });
                              // }
                            } else if (!rememberPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please agree to the processing of personal data')),
                              );
                            }
                          },
                          child: const Text('Se connecter'),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
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
                              'Se connecter avec',
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
                        height: 25.0,
                      ),
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
                                if (userCredential != null &&
                                    userCredential.user != null) {
                                  // Récupérer l'ID de l'utilisateur
                                  String userId = userCredential.user!.uid;

                                  // Rediriger l'utilisateur vers MyHomePage avec l'ID de l'utilisateur
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyHomePage(
                                        userId: userId,
                                      ),
                                    ),
                                  );
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
                      // don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Vous n\'avez pas de compte? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'S\'inscrire',
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

  Future<bool> _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      User? user =
          await AuthService().signInWithEmailAndPassword(email, password);

      if (user != null) {
        String userId = user.uid;
        print("Utilisateur connecté avec succès, son ID est: $userId");

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogSuccessWidget(userId: userId);
          },
        );

        return true;
      } else {
        print("Une erreur est survenue lors de la connexion");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogWidget();
          },
        );
        return false;
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");
      return false;
    }
  }
}
