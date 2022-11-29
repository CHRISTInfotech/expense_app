import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpense/shared/controller/theme_cubit.dart';

import './screens/wrapper.dart';
import './services/auth.dart';
import './models/user.dart';

Future<void> main() async {
  // Ensure all plugins are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  // Apply application UI overlay (FULL SCREEN)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
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
      runApp(MultiBlocProvider(
          providers: [BlocProvider(create: ((context) => ThemeCubit()))],
          child: MyApp(sharedPrefs: prefs)));
    });
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPrefs;
  MyApp({required this.sharedPrefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeCubit theme = BlocProvider.of<ThemeCubit>(context, listen: true);
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
        theme: theme.isDark ? ThemeData.dark() : ThemeData.light(),
      ),
    );
  }
}
