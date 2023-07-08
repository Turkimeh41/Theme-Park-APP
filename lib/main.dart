import 'dart:developer';

import 'package:final_project/AUTH_SCREEN/LOGIN_SCREEN/login_screen.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/MANAGERS/manager_data_container.dart';
import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:final_project/utility_provider.dart';
import 'package:final_project/USERS/splash_screen.dart';
import 'USERS/Provider/mode_theme_provider.dart';
import 'package:final_project/USERS/user_data_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart' as u;
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/transactions_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Utility utility = Utility()..checkRememberME();
  utility.setPrefLastUser();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp(utility: utility));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.utility});
  final Utility utility;
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
          create: (context) => ModeTheme(),
        ),
        ChangeNotifierProvider(
          create: (context) => AnonymousUsers(),
        ),
        ChangeNotifierProvider(
          create: (context) => ActivityEngagement(),
        ),
        Provider(
          create: (context) => Manager(),
        ),
        Provider(
          create: (context) => utility,
        ),
      ],
      child: Consumer<ModeTheme>(
        builder: (context, schemeMode, child) {
          return GetMaterialApp(
              themeMode: schemeMode.currentTheme,
              debugShowCheckedModeBanner: false,
              title: 'Swipe',
              darkTheme: ThemeData(),
              theme: ThemeData(
                  scaffoldBackgroundColor: const Color.fromARGB(255, 243, 235, 235),
                  primaryColor: const Color.fromARGB(255, 95, 3, 46),
                  dividerColor: const Color.fromARGB(255, 211, 198, 198),
                  secondaryHeaderColor: const Color.fromARGB(255, 109, 56, 81),
                  focusColor: const Color.fromARGB(255, 87, 0, 41),
                  appBarTheme: const AppBarTheme(
                      backgroundColor: Color.fromARGB(255, 87, 0, 41),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)))),
                  textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Color.fromARGB(255, 100, 21, 62), selectionColor: Color.fromARGB(255, 78, 23, 51), selectionHandleColor: Color.fromARGB(255, 78, 23, 51))),
              home: Consumer<Utility>(
                builder: (context, utility, child) {
                  return StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, streamSnapshot) {
                      log('userChanges Stream Changed!');
                      if (streamSnapshot.connectionState == ConnectionState.waiting) {
                        return SplashScreen(rocketNotifier: ValueNotifier(0), textNotifier: ValueNotifier('Fetching Activites'));
                      } else if (streamSnapshot.hasData) {
                        return utility.currentUserType == "user"
                            ? const UserDataContainer()
                            : utility.currentUserType == "manager"
                                ? const ManagerDataContainer()
                                : const LoginScreen();
                      } else {
                        return const LoginScreen();
                      }
                    },
                  );
                },
              ));
        },
      ),
    );
  }
}
