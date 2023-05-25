// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/AUTH_SCREEN/LOGIN_SCREEN/login_screen.dart';
import 'package:final_project/Handler/general_handler.dart';
import 'package:final_project/Handler/manager_firebase_handler.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/main_menu.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/utility_provider.dart';
import 'package:final_project/USERS/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagerDataContainer extends StatefulWidget {
  const ManagerDataContainer({super.key});

  @override
  State<ManagerDataContainer> createState() => _ManagerDataContainerState();
}

class _ManagerDataContainerState extends State<ManagerDataContainer> {
  final ValueNotifier<int> rocketNotifier = ValueNotifier(0);
  final ValueNotifier<String> textNotifier = ValueNotifier('Fetching Activites');

  Future<void> fetchData(BuildContext context) async {
    await GeneralHandler.setCurrentUser('manager');
    await ManagerFirebaseHandler.setLastLogin();
    await Provider.of<Activites>(context, listen: false).fetchActivites();
    await Future.delayed(const Duration(milliseconds: 1200));
    textNotifier.value = 'Fetching and setting Manager data';
    await Provider.of<Manager>(context, listen: false).setManager();
    await Future.delayed(const Duration(milliseconds: 700));
    textNotifier.value = "Done!";
    rocketNotifier.value = 1;
    await Future.delayed(const Duration(milliseconds: 1200));
  }

  @override
  Widget build(BuildContext context) {
    final utility = Provider.of<Utility>(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Manager_Enabled").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (streamSnapshot.hasData) {
            final enabledDoc = streamSnapshot.data!.data();
            if (enabledDoc!['enabled'] == true) {
              return FutureBuilder(
                  future: fetchData(context),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState == ConnectionState.waiting) {
                      return SplashScreen(rocketNotifier: rocketNotifier, textNotifier: textNotifier);
                    } else {
                      return const ManagerMainMenu();
                    }
                  });
            } else {
              if (FirebaseAuth.instance.currentUser != null) {
                FirebaseAuth.instance.signOut();
                utility.clearCurrentUser();
              }
              return const LoginScreen();
            }
          } else {
            return const LoginScreen();
          }
        });
  }
}
