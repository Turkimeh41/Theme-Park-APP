import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:final_project/Screen_1/mainmenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
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
              return const MainMenu();
            } else {
              return const LoginScreen();
            }
          },
        ));
  }
}
