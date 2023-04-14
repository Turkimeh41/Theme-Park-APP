// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  late final String username;
  late String first_name;
  late String last_name;
  late double balance;
  late final String phone_number;
  late final DateTime registered;
  late final int gender;

  Future<void> setUser() async {
    final documentReference = await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    username = documentReference['username'];
    first_name = documentReference['first_name'];
    last_name = documentReference['last_name'];
    balance = documentReference['balance'];
    phone_number = documentReference['phone_number'];
    registered = (documentReference['registered'] as Timestamp).toDate();
    gender = documentReference['gender'];
  }

  Future<void> editProfile(String first_name, String last_name) async {}
}
