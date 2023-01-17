import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

void showOTPDialog({
  required BuildContext context,
  required TextEditingController codeController,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CO\nDE',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 80.0,
            ),
          ),
          Text(
            'Verification'.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 40.0,
          ),
          const Text(
            'Enter the verification code sent at alansomathew10@gmail.com ',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20.0,
          ),
          OtpTextField(
            numberOfFields: 6,
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
          ),
          SizedBox(
            height: 20.0,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              child: const Text(
                'Next',
              ),
            ),
          )
        ],
      ),
    ),
  );
}
