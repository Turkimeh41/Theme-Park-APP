import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:final_project/Provider/mode_provider.dart' as mode;
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription subscription;
  @override
  void initState() {
    subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {});
    });
    super.initState();
  }

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
        ),
        ChangeNotifierProvider(
          create: (context) => mode.ThemeMode(),
        )
      ],
      child: Consumer<mode.ThemeMode>(
        builder: (context, schemeMode, child) {
          return GetMaterialApp(
              themeMode: schemeMode.currentTheme,
              debugShowCheckedModeBanner: false,
              title: 'Swipe',
              darkTheme: ThemeData(),
              theme: ThemeData(
                  primaryColor: const Color.fromARGB(255, 95, 3, 46),
                  dividerColor: const Color.fromARGB(255, 211, 198, 198),
                  secondaryHeaderColor: const Color.fromARGB(255, 109, 56, 81),
                  focusColor: const Color.fromARGB(255, 87, 0, 41),
                  appBarTheme: const AppBarTheme(
                      backgroundColor: Color.fromARGB(255, 87, 0, 41),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)))),
                  textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Color.fromARGB(255, 100, 21, 62), selectionColor: Color.fromARGB(255, 78, 23, 51), selectionHandleColor: Color.fromARGB(255, 78, 23, 51))),
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (streamSnapshot.hasData) {
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance.collection("User_Enabled").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                        builder: (context, streamSnapshot1) {
                          if (streamSnapshot1.connectionState == ConnectionState.waiting) {
                            log('waiting...');
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (streamSnapshot1.hasData) {
                            final documentSnapshot = streamSnapshot1.data;
                            final data = documentSnapshot!.data();
                            bool enabled = data!['enabled'];
                            if (enabled) {
                              return const DataContainer();
                            } else {
                              if (FirebaseAuth.instance.currentUser != null) {
                                FirebaseAuth.instance.signOut();
                              }
                              return const LoginScreen();
                            }
                          } else {
                            return const LoginScreen();
                          }
                        });
                  } else {
                    return const LoginScreen();
                  }
                },
              ));
        },
      ),
    );
  }
}
