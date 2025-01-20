import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:velocity_x/velocity_x.dart';

class CustomDialogWidget extends StatelessWidget {
  const CustomDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          const CardDialog(),
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
  const CardDialog({
    super.key,
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
            'lib/assets/index.jpeg',
            width: 72,
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            'Alert',
            style: GoogleFonts.montserrat(
                fontSize: 24,
                color: const Color(0xffEC5B5B),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            "Email ou Mot de Passe Incorrect! Veuillez reessayer",
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
                    CircularProgressIndicator();
                    Navigator.of(context).pop();
                  },
                  child: const Text('yes'))
            ],
          )
        ],
      ),
    );
  }
}
