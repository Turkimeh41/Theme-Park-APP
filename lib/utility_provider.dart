// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:final_project/USERS/Provider/transactions_provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart' as u;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as g;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  String _currentUserType = '';
  StreamSubscription? userEnabledStream;
  StreamSubscription? managerEnabledStream;
  Future<void> setPrefLastUser() async {
    final pref = await SharedPreferences.getInstance();
    final currentUser = (pref.get('type') ?? '') as String;
    _currentUserType = currentUser;
  }

  String get currentUserType {
    return _currentUserType;
  }

  Future<void> checkRememberME() async {
    final pref = await SharedPreferences.getInstance();
    bool? value = pref.getBool('remember-me') ?? true;

    //remember me is true!
    if (value) {
      return;
    } else if (!value) {
      log('false, logging out!');
      await FirebaseAuth.instance.signOut();
      _currentUserType = '';
      pref.remove('remember-me');
    }
  }

  Future<void> refesh(BuildContext context) async {
    await Provider.of<u.User>(context, listen: false).setUser();
    await Provider.of<Activites>(context, listen: false).fetchActivites();
    await Provider.of<Transactions>(context, listen: false).fetchTransactions();
    await Provider.of<Participations>(context, listen: false).fetchParticipations();
  }

  Future<void> initializeUserENABLEDStream() async {
    userEnabledStream = FirebaseFirestore.instance.collection('User_Enabled').doc(FirebaseAuth.instance.currentUser!.uid).snapshots().listen((event) async {
      final documentSnapshot = await FirebaseFirestore.instance.collection('User_Enabled').doc(FirebaseAuth.instance.currentUser!.uid).get();

      log('the User stream emmitted new values!');
      final data = documentSnapshot.data();
      final enabled = data!['enabled'];
      log('the enabled value is: $enabled');
      if (enabled == true) {
        return;
      } else {
        g.Get.back();
        g.Get.showSnackbar(g.GetSnackBar(
          duration: const Duration(seconds: 2),
          messageText: Text(
            'YOU\'VE BEEN DISABLED.',
            style: GoogleFonts.signika(color: Colors.red),
          ),
          backgroundColor: const Color.fromARGB(255, 26, 25, 25),
        ));

        await userEnabledStream!.cancel();
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<void> initializeManagerENABLEDStream() async {
    managerEnabledStream = FirebaseFirestore.instance.collection('Manager_Enabled').doc(FirebaseAuth.instance.currentUser!.uid).snapshots().listen((documentSnapshot) async {
      final documentSnapshot = await FirebaseFirestore.instance.collection('Manager_Enabled').doc(FirebaseAuth.instance.currentUser!.uid).get();
      final data = documentSnapshot.data();
      if (data!['enabled'] == true) {
        return;
      } else {
        g.Get.back();
        g.Get.showSnackbar(g.GetSnackBar(
          duration: const Duration(seconds: 2),
          messageText: Text(
            'YOU\'VE BEEN DISABLED.',
            style: GoogleFonts.signika(color: const Color.fromARGB(255, 212, 40, 28)),
          ),
          backgroundColor: const Color.fromARGB(255, 26, 25, 25),
        ));
        await managerEnabledStream!.cancel();
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<void> clearCurrentUser() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('type');
  }

  Future<void> setCurrentUser(String type) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('type', type);
    _currentUserType = type;
  }

  Future<void> userlogout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('remember-me');
    await clearCurrentUser();
    await userEnabledStream!.cancel();
    await FirebaseAuth.instance.signOut();
    g.Get.showSnackbar(g.GetSnackBar(
      duration: const Duration(seconds: 2),
      messageText: Text(
        'LOGUOUT SUCCESSFUL!.',
        style: GoogleFonts.signika(color: const Color.fromARGB(255, 52, 184, 56)),
      ),
      backgroundColor: const Color.fromARGB(255, 26, 25, 25),
    ));
  }

  Future<void> managerLogout() async {
    await clearCurrentUser();
    g.Get.back();
    await managerEnabledStream!.cancel();
    await FirebaseAuth.instance.signOut();
    g.Get.showSnackbar(g.GetSnackBar(
      duration: const Duration(seconds: 2),
      messageText: Text(
        'LOGUOUT SUCCESSFUL!.',
        style: GoogleFonts.signika(color: const Color.fromARGB(255, 52, 184, 56)),
      ),
      backgroundColor: const Color.fromARGB(255, 26, 25, 25),
    ));
  }
}
