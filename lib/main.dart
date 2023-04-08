import 'dart:developer';

import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:final_project/Auth_Screens/Register_Screen/verifynumberscreen.dart';
import 'package:final_project/Main_Menu/mainmenu_screen.dart';
import 'package:final_project/Provider/userauth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await checkPref();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

Future<void> checkPref() async {
  final pref = await SharedPreferences.getInstance();
  bool stored = pref.getBool('log-out') ?? false;
  if (stored) {
    log('Logging out...');
    FirebaseAuth.instance.signOut();
    pref.remove('log-out');
  } else {
    log('No SharedPref');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SWIPEZ',
        theme: ThemeData(
            textSelectionTheme:
                const TextSelectionThemeData(cursorColor: Color.fromARGB(255, 100, 21, 62), selectionColor: Color.fromARGB(255, 78, 23, 51), selectionHandleColor: Color.fromARGB(255, 78, 23, 51))),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const MainMenuScreen();
            } else {
              return const LoginScreen();
            }
          },
        ));
  }
}
