import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

Future<void> showOTPDialog({
  required BuildContext context,
 required TextEditingController codeController,
  required VoidCallback onPressed,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(
        'CO\nDE',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 40.0,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: codeController,
          ),
          // Pinput(
          //   length: 6,
          //   // defaultPinTheme: defaultPinTheme,
          //   // focusedPinTheme: focusedPinTheme,
          //   // submittedPinTheme: submittedPinTheme,

          //   showCursor: true,
          //   onChanged: (value) {},
          //   onCompleted: (value) {
          //     print(value);
          //   },
          // ),
         
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Done"),
          onPressed: onPressed,
        )
      ],
    ),
  );
}
