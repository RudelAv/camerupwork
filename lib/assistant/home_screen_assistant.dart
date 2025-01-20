import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pfe/assistant/message_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreenAssistant extends StatefulWidget {
  const HomeScreenAssistant({super.key});

  @override
  State<HomeScreenAssistant> createState() => _HomeScreenAssistantState();
}

class _HomeScreenAssistantState extends State<HomeScreenAssistant> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  // Variables pour stocker le contexte du document
  String _documentType = '';
  String _projectInfo = '';
  String _tone = '';

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyAEghjtrerfBZ_ehvcd-YsKt5qhaq7Ixk8',
    );
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build with Gemini'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatSession.history.length,
                itemBuilder: (context, index) {
                  final Content content = _chatSession.history.toList()[index];
                  final text = content.parts
                      .whereType<TextPart>()
                      .map<String>((e) => e.text)
                      .join('');
                  return MessageWidget(
                      text: text, isFromUser: content.role == 'user');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            focusNode: _textFieldFocus,
                            decoration: textFieldDecoration(),
                            controller: _textController,
                            onSubmitted: _sendChatMessage,
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
        contentPadding: const EdgeInsets.all(15),
        hintText: 'Enter a prompt...',
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            )));
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    // Extraire le contexte du message
    if (message.contains('Proposition')) {
      _documentType = 'Proposition';
    } else if (message.contains('Contrat')) {
      _documentType = 'Contrat';
    } else {
      _documentType = '';
    }

    if (message.contains('site web e-commerce')) {
      _projectInfo =
          'Je suis un développeur web indépendant et je veux proposer mes services pour un projet de site web e-commerce.';
    }

    if (message.contains('professionnel et persuasif')) {
      _tone = 'professionnel et persuasif';
    } else {
      _tone = '';
    }

    try {
      final response = await _chatSession.sendMessage(
        Content.text(
            'Écris un document de type $_documentType pour un projet de $_projectInfo. Utilise un style $_tone.  ${message}'),
      );

      // Formatage de la réponse
      final text = response.text;

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(
                milliseconds: 750,
              ),
              curve: Curves.easeOutCubic,
            ));
  }

  void _showError(String message) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Something went wrong'),
            content: SingleChildScrollView(
              child: SelectableText(message),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        });
  }
}
