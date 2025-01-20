import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_multi_select/dropdown_multi_select.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Importer la librairie Gemini

class CreationProfil extends StatefulWidget {
  final String userId;
  // final notificationToken;

  const CreationProfil({super.key, required this.userId});

  @override
  State<CreationProfil> createState() => _CreationProfilState();
}

class _CreationProfilState extends State<CreationProfil> {
  final _presentationController = TextEditingController();
  final _picker = ImagePicker();
  File? _profileImage;
  String? _profileImageUrl;

  String _selectedActivity = '';
  String _selectedSpecialty = '';
  String _selectedRegion = '';

  List<String> competences = [];
  List<String> availableSpecialties = [];
  List<String> availableCompetences = [
    // Toutes les compétences disponibles
    'Flutter',
    'React Native',
    'Android Studio',
    'iOS Development',
    'Kotlin',
    'Swift',
    'Java',
    'Dart',
    'Python',
    'C#',
    'C++',
    'JavaScript',
    'PHP',
    'SQL',
    'Agile',
    'Adobe Photoshop',
    'Adobe Illustrator',
    'Adobe InDesign',
    'Figma',
    'UI/UX Design',
    'Branding',
    'Typography',
    'Adobe Premiere Pro',
    'Final Cut Pro',
    'After Effects',
    'Motion Graphics',
    'Video Editing',
    'Color Grading',
    'Copywriting',
    'Social Media Marketing',
    'Content Strategy',
    'SEO',
    'Blogging',
    'Storytelling',
    'Data Visualization',
    'Infographic Design',
    'Information Design',
    'HTML',
    'CSS',
    'React',
    'Angular',
    'WordPress',
    'Web Design',
  ];

  // Map pour associer les activités aux spécialités
  final Map<String, List<String>> activitySpecialties = {
    'Création d\'applications': [
      'Développement mobile',
      'Développement d’applications'
    ],
    'Création de logiciels': [
      'Développement logiciel',
      'Ingénierie logicielle'
    ],
    'Graphic Design': ['Graphisme', 'Design UI/UX', 'Illustration'],
    'Montage vidéo': ['Montage vidéo', 'Animation', 'Motion Design'],
    'Création de contenu': [
      'Rédaction web',
      'Marketing de contenu',
      'Gestion des médias sociaux'
    ],
    'Infographie': ['Infographie', 'Data Visualisation'],
    'Création et déploiement de sites web': ['Développement web', 'Design web'],
  };

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  int currentStep = 0;
  bool _isLoading = false;

  continueStep() async {
    if (currentStep < 2) {
      setState(() {
        currentStep = currentStep + 1;
      });
    } else {
      if (currentStep == 2) {
        setState(() {
          _isLoading = true;
        });

        FirebaseAuth auth = FirebaseAuth.instance;
        User? user = auth.currentUser;

        if (user != null) {
          String userId = user.uid;
          print(userId);
          CollectionReference usersRef =
              FirebaseFirestore.instance.collection('Users');
          DocumentReference userDocRef = usersRef.doc(userId);
          CollectionReference freelanceRef = userDocRef.collection('freelance');

          if (_profileImage != null) {
            // Enregistrer la photo de profil dans Firebase Storage
            _profileImageUrl = await uploadImageToStorage(_profileImage!,
                'user_profile/${userId}'); // Ajout de l'ID utilisateur au chemin
          }

          // Enregistrer les autres informations dans Firestore
          await freelanceRef.doc(userId).set({
            'competences': competences,
            'specialite': _selectedSpecialty,
            'presentation': _presentationController.text,
            'photoProfil': _profileImageUrl, // Insérer l'URL de l'image
            'localisation': _selectedRegion,
            'activite': _selectedActivity, // Insérer l'activité choisie
            'typeTravail': 'en ligne', // Ajouter le champ 'typeTravail'
          });

          // Mettre à jour le document de l'utilisateur dans la collection 'Users'
          await userDocRef.update({
            'typeTravail': 'en ligne',
            // Ajouter les autres champs ici
            'competences': competences,
            'specialite': _selectedSpecialty,
            'presentation': _presentationController.text,
            'photoProfil': _profileImageUrl,
            'localisation': _selectedRegion,
            'activite': _selectedActivity,
          });

          // Naviguez vers la prochaine page après avoir enregistré les informations
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(
                      userId: widget.userId,
                    )),
          );
        }
      }
    }
  }

  cancelStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep = currentStep - 1;
      });
    }
  }

  onStepTapped(int value) {
    setState(() {
      currentStep = value;
    });
  }

  Widget controlBuilder(context, details) {
    return Row(
      children: [
        ElevatedButton(
            onPressed: details.onStepContinue, child: const Text('Next')),
        const SizedBox(
          width: 10,
        ),
        OutlinedButton(
            onPressed: details.onStepCancel, child: const Text('Back'))
      ],
    );
  }

  Future<String?> uploadImageToStorage(File imageFile, String folder) async {
    // Téléchargement de l'image dans Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(folder);
    final uploadTask = imageRef.putFile(imageFile);

    await uploadTask.then((snapshot) async {
      // Récupérer l'URL de l'image téléchargée
      _profileImageUrl = await imageRef.getDownloadURL();
    });

    return _profileImageUrl;
  }

  @override
  void initState() {
    super.initState();
    // Mise à jour des compétences disponibles lors du chargement de la page
    _updateSpecialties(_selectedActivity); // Initialisation
  }

  void _updateSpecialties(String activity) {
    setState(() {
      availableSpecialties = activitySpecialties[activity] ?? [];
    });
  }

  // Fonction pour générer la présentation avec Gemini
  Future<void> _generatePresentation() async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey:
          'AIzaSyAEghjtrerfBZ_ehvcd-YsKt5qhaq7Ixk8', // Remplacez par votre clé API Gemini
    );
    final session = model.startChat();

    final prompt =
        "Je suis un ${_selectedSpecialty} spécialisé dans ${_selectedActivity} avec les compétences suivantes: ${competences.join(', ')}.  Écrivez une présentation professionnelle et persuasive pour mon profil de freelance.";

    try {
      final response = await session.sendMessage(Content.text(prompt));
      final text = response.text;

      if (text != null) {
        setState(() {
          _presentationController.text = text;
        });
      } else {
        // Gérer les erreurs de réponse de Gemini
        print("Erreur de génération de présentation");
      }
    } catch (e) {
      // Gérer les erreurs lors de l'appel à Gemini
      print("Erreur lors de l'appel à Gemini: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Stepper(
              margin: const EdgeInsets.all(60),
              physics: const ClampingScrollPhysics(),
              elevation: 0,
              type: StepperType.vertical,
              currentStep: currentStep,
              onStepContinue: continueStep,
              onStepCancel: cancelStep,
              onStepTapped: onStepTapped,
              controlsBuilder: controlBuilder,
              steps: [
                Step(
                  title: const Text('Compétences'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Affichage de la selection de l'activité
                      DropdownButtonFormField<String>(
                        hint: const Text('Choisir une activité'),
                        items: [
                          'Création d\'applications',
                          'Création de logiciels',
                          'Graphic Design',
                          'Montage vidéo',
                          'Création de contenu',
                          'Infographie',
                          'Création et déploiement de sites web',
                        ]
                            .map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedActivity = value!;
                            // Mise à jour des spécialités disponibles
                            _updateSpecialties(_selectedActivity);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text('Choisissez vos compétences'),
                      const SizedBox(height: 16),
                      DropdownMultiSelect(
                        dropdownValueList:
                            availableCompetences, // Afficher toutes les compétences
                        selectedTileColor: Colors.lightBlue,
                        hintStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                        decoration: BoxDecoration(border: Border.all()),
                        deleteIconColor: Colors.red,
                        hint: "Selectionnez Vos Competences",
                        onChanged: (List<String> x) {
                          setState(() {
                            competences = x;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        hint: const Text('Choisir une spécialité'),
                        items: availableSpecialties
                            .map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(), // Utiliser les spécialités disponibles
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecialty = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mettez toutes les chances de votre côté en fournissant des informations complémentaires aux clients : votre parcours professionnel, vos compétences, votre méthode de travail, etc.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _presentationController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Écrivez votre présentation ici...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  isActive: currentStep >= 0,
                  state: currentStep >= 0
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: const Text('Photo de profil'),
                  content: Column(
                    children: [
                      if (_profileImage != null)
                        Image.file(
                          _profileImage!,
                          height: 100,
                          width: 100,
                        )
                      else
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('lib/assets/th.jpg'),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickProfileImage,
                        child: const Text('Choisir une image'),
                      ),
                    ],
                  ),
                  isActive: currentStep >= 1,
                  state: currentStep >= 1
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: const Text('Localisation'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sélectionnez votre région'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        hint: const Text('Choisir une ville'),
                        items: const [
                          'Yaoundé',
                          'Douala',
                          'Garoua',
                          'Bamenda',
                          'Maroua',
                          'Bertoua',
                          'Kumba',
                          'Ebolowa',
                          'Bafoussam',
                          'Nkongsamba',
                          'Limbe',
                          'Kribi',
                          'Buea',
                          'Dschang'
                        ]
                            .map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: currentStep >= 2,
                  state: currentStep >= 2
                      ? StepState.complete
                      : StepState.disabled,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePresentation, // Appel à la fonction de génération
        child: const Icon(Icons.lightbulb),
      ),
    );
  }
}
