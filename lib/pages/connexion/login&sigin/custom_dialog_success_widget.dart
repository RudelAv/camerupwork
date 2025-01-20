import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pfe/pages/accueil/MyhomePage.dart';

class CustomDialogSuccessWidget extends StatelessWidget {
  final String userId;
  const CustomDialogSuccessWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          CardDialog(userId: userId),
          Positioned(
              top: 0,
              right: 0,
              height: 38,
              width: 38,
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      shape: const CircleBorder(),
                      backgroundColor: const Color(0xffEC5B5B)),
                  child: Image.asset(
                    'lib/assets/index.png',
                  )))
        ],
      ),
    );
  }
}

class CardDialog extends StatelessWidget {
  final String userId;
  const CardDialog({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xff2A303E),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/assets/images.png',
            width: 72,
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            'Notification',
            style: GoogleFonts.montserrat(
                fontSize: 24,
                color: const Color(0xff5BEC84),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            "Authentification reussie",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                    foregroundColor: const Color(0XffEC5B5B)),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5BEC84),
                      foregroundColor: const Color(0xff2A303E),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 32)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyHomePage(
                                userId: userId,
                              )),
                    );
                  },
                  child: const Text('Ok'))
            ],
          )
        ],
      ),
    );
  }
}
