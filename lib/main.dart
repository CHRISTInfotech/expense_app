import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/wrapper.dart';
import './services/auth.dart';
import './models/user.dart';

Future<void> main() async {
  // Ensure all plugins are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Apply application UI overlay (FULL SCREEN)

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]).then((_) {
    // Retrieve stored preferences before starting application
    Future<SharedPreferences> sharedPrefs = SharedPreferences.getInstance();
    sharedPrefs.then((prefs) {
      var initialLoad = prefs.getBool(
            'initialLoad',
          ) ??
          true;
      if (initialLoad) {
        prefs.setBool('initialLoad', initialLoad);
      }
      runApp(MyApp(sharedPrefs: prefs));
    });
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPrefs;
  MyApp({required this.sharedPrefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Restrict portrait mode only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Retrieve User object from stream
    return StreamProvider.value(
      value: AuthService().user,

      //ApplicationR

      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Wrapper(sharedPrefs),
      ),
    );
  }
}
