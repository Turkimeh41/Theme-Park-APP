import 'dart:developer';

import 'package:final_project/Auth_Screens/Login_Screen/forget_password.dart';
import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:final_project/Main_Menu/ACCOUNT_SCREEN/account_screen.dart';
import 'package:final_project/Main_Menu/TRANSACTION_SCREEN/transaction_screen.dart';
import 'package:final_project/data_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:final_project/Provider/user_provider.dart' as u;
import 'package:final_project/Provider/activites_provider.dart';
import 'package:final_project/Provider/transactions_provider.dart';
import 'package:final_project/Provider/participations_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await checkPref();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

Future<void> checkPref() async {
  final pref = await SharedPreferences.getInstance();
  bool? value = pref.getBool('remember-me') ?? true;
  //remember me is true!
  if (value) {
    log('remember me is true or null');
    log('no logging out');
    return;
  } else if (!value) {
    log('remember me is false');
    log('procceding, logging out..');
    await FirebaseAuth.instance.signOut();
    pref.remove('remember-me');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Transactions(),
        ),
        ChangeNotifierProvider(
          create: (context) => Activites(),
        ),
        ChangeNotifierProvider(
          create: (context) => u.User(),
        ),
        ChangeNotifierProvider(
          create: (context) => Participations(),
        )
      ],
      child: GetMaterialApp(
          routes: {
            ForgetPassword.routeName: (context) => const ForgetPassword(),
            AccountScreen.routeName: (context) => const AccountScreen(),
            TransactionScreen.route: (context) => const TransactionScreen()
          },
          debugShowCheckedModeBanner: false,
          title: 'SWIPEZ',
          theme: ThemeData(
              focusColor: const Color.fromARGB(255, 87, 0, 41),
              appBarTheme: const AppBarTheme(
                  backgroundColor: Color.fromARGB(255, 87, 0, 41), shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)))),
              textSelectionTheme:
                  const TextSelectionThemeData(cursorColor: Color.fromARGB(255, 100, 21, 62), selectionColor: Color.fromARGB(255, 78, 23, 51), selectionHandleColor: Color.fromARGB(255, 78, 23, 51))),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const DataContainer();
              } else {
                return const LoginScreen();
              }
            },
          )),
    );
  }
}
