import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import './theme.dart';
import '../data/globals.dart' as globals;

const kAppName = "DollarSense";
const kAppLogo = 'assets/images/dollarsense_logo.png';
const kDev = "Crystal Cheong";
const kDevEmail = "crystalcheongyq@gmail.com";

void launchMailClient() async {
  const mailUrl = 'mailto:$kDevEmail';
  try {
    await launch(mailUrl);
  } catch (e) {
    copyMailClient(globals.scaffoldKey);
  }
}

void copyMailClient(GlobalKey<ScaffoldMessengerState> key ) async {
    await Clipboard.setData(new ClipboardData(text: kDevEmail));
    key.currentState!.showSnackBar(new SnackBar(
      backgroundColor: kDarkSecondary,
      content: new Text("Copied to Clipboard")
    ));
}
