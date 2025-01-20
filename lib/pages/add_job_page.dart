import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pfe/widget/drawer_menu_widget.dart';

class AddJobPage extends StatefulWidget {
  final VoidCallback openDrawer;
  final String userId;
  const AddJobPage({
    super.key,
    required this.openDrawer,
    required this.userId,
  });

  @override
  _AddJobPageState createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  // final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _selectedType;
  String? _selectedCity;
  String? _selectedCategory;
  final List<String> _jobTypes = ['Sur site', 'A distance'];
  final List<String> _cities = [
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
  ];
  final List<String> _onsiteCategories = [
    'Plomberie',
    'Charpenterie',
    'Soudure',
    'Menuiserie',
    'Artisanat',
    'Construction'
  ];
  final List<String> _remoteCategories = [
    'Création d\'applications',
    'Création de logiciels',
    'Graphic Design',
    'Montage vidéo',
    'Création de contenu',
    'Infographie',
    'Création et déploiement de sites web',
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submitProject() async {
    // Validation des champs (sans utiliser le widget Form)
    if (_titleController.text.isEmpty ||
        _selectedType == null ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _budgetController.text.isEmpty ||
        double.tryParse(_budgetController.text) == null) {
      // Afficher un message d'erreur si les champs ne sont pas valides
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content:
                const Text('Veuillez remplir tous les champs correctement'),
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
      return;
    }

    // Récupérer le nom de l'utilisateur et son image de profil
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .get();
    final userName = userDoc.get('username');

    // Obtenir l'URL de la photo de profil
    String? userImageUrl;

    // Vérifier la sous-collection TravailleurPresentiel
    final travailleurPresentielSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('TravailleurPresentiel')
        .get();

    // Vérifier la sous-collection freelance
    final freelanceSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('freelance')
        .get();

    // Si aucune des deux sous-collections n'est trouvée, utiliser la photo de profil dans la collection Users
    if (travailleurPresentielSnapshot.docs.isEmpty &&
        freelanceSnapshot.docs.isEmpty) {
      userImageUrl = userDoc.get('photoProfil');
    } else {
      // Sinon, prendre l'URL de la photo de profil depuis la sous-collection appropriée
      if (travailleurPresentielSnapshot.docs.isNotEmpty) {
        userImageUrl = travailleurPresentielSnapshot.docs.first.get('imageUrl');
      } else {
        userImageUrl = freelanceSnapshot.docs.first.get('photoProfil');
      }
    }

    // Enregistrer les données du projet dans Firestore
    try {
      await FirebaseFirestore.instance.collection('Projets').add({
        'Budget': double.parse(_budgetController.text),
        'dateAjout': DateTime.now(),
        'description': _descriptionController.text,
        'titre': _titleController.text,
        'id_user': widget.userId,
        'nomClient': userName,
        'image': userImageUrl,
        'typeTravail': _selectedType,
        'categorie': _selectedCategory,
        'ville': _selectedCity,
        'statut': 'ouvert', // Ajoutez le statut "ouvert" par défaut
      });

      // Effacer les champs après la soumission
      _titleController.clear();
      _descriptionController.clear();
      _budgetController.clear();
      _selectedType = null;
      _selectedCategory = null;
      _selectedCity = null;

      // Afficher un message de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Projet soumis avec succès!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Afficher un message d'erreur si l'enregistrement a échoué
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Erreur lors de la soumission du projet: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> generateDescription() async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey:
          'AIzaSyAEghjtrerfBZ_ehvcd-YsKt5qhaq7Ixk8', // Remplacez par votre clé API Gemini
    );
    final session = model.startChat();

    final prompt =
        "Je recherche des candidatures pour réaliser un projet ${_selectedType} dans la catégorie ${_selectedCategory} ${_selectedCity != null ? "à $_selectedCity" : ""}. Le projet s'intitule ${_titleController.text} et a un budget de ${_budgetController.text}. Écrivez une description concise et persuasive pour cet appel à candidature, en mettant l'accent sur les compétences et les expériences nécessaires pour réussir ce projet. Veuillez utiliser des phrases claires et éviter d'utiliser des astérisques pour les mots clés, mettez les plutot en gras.";

    try {
      setState(() {
        _isLoading = true;
      });
      final response = await session.sendMessage(Content.text(prompt));
      final text = response.text;

      if (text != null) {
        // Supprimez les astérisques
        final formattedText = text.replaceAll(RegExp(r'\*'), '');

        setState(() {
          _descriptionController.text = formattedText;
          _isLoading = false;
        });
      } else {
        // Gérer les erreurs de réponse de Gemini
        print("Erreur de génération de description");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Gérer les erreurs lors de l'appel à Gemini
      print("Erreur lors de l'appel à Gemini: ${e.toString()}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text("Deposer un Projet")),
        leading: DrawerMenuWidget(
          onClicked: widget.openDrawer,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre du projet
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du projet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Type de travail
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Choisissez un type de travail'),
                  value: _selectedType,
                  items: _jobTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),

              // Ville (si type de travail est 'Sur site')
              if (_selectedType == 'Sur site')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Choisissez une ville'),
                    value: _selectedCity,
                    items: _cities.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCity = newValue;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16.0),

              // Budget du projet
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget du projet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // Sélection de la catégorie
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Choisissez une catégorie'),
                  value: _selectedCategory,
                  items: (_selectedType == 'Sur site'
                          ? _onsiteCategories
                          : _remoteCategories)
                      .map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),

              // Champ de description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description du projet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  suffixIcon: IconButton(
                    onPressed: generateDescription,
                    icon: Icon(Icons.lightbulb_outline),
                  ),
                ),
                maxLines: 5,
                readOnly:
                    _isLoading, // Désactiver la saisie si l'IA est en cours
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 16.0),

              // Bouton Soumettre
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, // Couleur bleue pour le bouton
                  ),
                  onPressed: _submitProject,
                  child: const Text('Soumettre le projet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
