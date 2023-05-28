// ignore_for_file: unused_import, use_build_context_synchronously

import 'package:chalkdart/chalk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/AUTH_SCREEN/LOGIN_SCREEN/login_screen.dart';
import 'package:final_project/Handler/general_handler.dart';
import 'package:final_project/Handler/user_firebase_handler.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:final_project/utility_provider.dart';
import 'package:final_project/USERS/stream_listener.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'Provider/activites_provider.dart';
import 'Provider/transactions_provider.dart';
import 'Provider/user_provider.dart' as u;
import 'dart:developer';
import 'splash_screen.dart';
import 'Provider/mode_theme_provider.dart';

class UserDataContainer extends StatefulWidget {
  const UserDataContainer({super.key});

  @override
  State<UserDataContainer> createState() => _UserDataContainerState();
}

class _UserDataContainerState extends State<UserDataContainer> {
  ValueNotifier<int> rocketNotifier = ValueNotifier(0);
  ValueNotifier<String> textNotifier = ValueNotifier('Fetching Activites');

  Future<void> _fetchData(BuildContext context) async {
    await UserFirebaseHandler.setLastLogin();
    await Provider.of<Activites>(context, listen: false).fetchActivites();
    await Provider.of<Activites>(context, listen: false).preloadImages(context);
    await Provider.of<Participations>(context, listen: false).fetchParticipations();
    await Future.delayed(const Duration(milliseconds: 1300));
    textNotifier.value = ("Fetching Transactions...");
    await Future.delayed(const Duration(milliseconds: 600));
    await Provider.of<Transactions>(context, listen: false).fetchTransactions();
    textNotifier.value = ("fetching and setting\n up user information");
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<u.User>(context, listen: false).setUser();

    textNotifier.value = "Done!";
    rocketNotifier.value = 1;
    await Future.delayed(const Duration(milliseconds: 1200));
  }

  @override
  Widget build(BuildContext context) {
    final utility = Provider.of<Utility>(context);
    utility.initializeUserENABLEDStream();
    return FutureBuilder(
        future: _fetchData(context),
        builder: (context, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(rocketNotifier: rocketNotifier, textNotifier: textNotifier);
          } else {
            return const StreamListener();
          }
        });
  }
}
