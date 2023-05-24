// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Model/activity.dart';
import 'package:final_project/Provider/participations_provider.dart';
import 'package:final_project/Provider/transactions_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Provider/user_provider.dart' as u;

//This is the instance of my firebase cloud functions object, which has all the functions i've created
final function = FirebaseFunctions.instanceFor(region: "europe-west1");

class FirebaseHandler {
  static Future<String> sendSMSTwilio(String phone) async {
    final response = await function.httpsCallable('sendSMSTwilio').call({'phone_number': "+966${phone.replaceAll(RegExp(r"\s+\b|\b\s"), '')}"});
    return response.data['smscode'];
  }

  static Future<void> userExists(String username, String email, String phone) async {
    await function.httpsCallable('existsUser').call({'username': username, 'email': email, 'phone': phone});
  }

  static Future<Map<String, dynamic>> addUser(String username, String password, String firstName, String lastName, String email, String phone, int gender) async {
    final response =
        await function.httpsCallable('addUser').call({'username': username, 'password': password, 'first_name': firstName, 'last_name': lastName, 'email': email, 'gender': gender, 'phone': phone});

    return {'token': response.data['token']};
  }

  static Future<String> loginUser(String username, String password) async {
    final result = await function.httpsCallable('loginUser').call({'username': username, 'password': password});
    return result.data['token'];
  }

  static Future<void> loginToken(String token) async {
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }

  static Future<void> setLastLogin() async {
    await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).set({"last_login": Timestamp.now()}, SetOptions(merge: true));
  }

  static Future<void> _deduceBalance(String userID, double balance) async {
    await FirebaseFirestore.instance.collection("Users").doc(userID).update({"balance": balance});
  }

  static Future<void> attemptPayment(Activity activity, u.User user, Participations insParticipations, Transactions insTransactions) async {
    if (user.balance >= activity.price) {
      log('balance is sufficent!');
      user.balance = user.balance - activity.price;
      await Future.wait([
        _deduceBalance(FirebaseAuth.instance.currentUser!.uid, user.balance),
        _incrementOnePlayedActivity(activity.id),
        _newParticipation(activity, insParticipations),
        _newTransaction(activity, insTransactions),
        _switchEngagement(activity.duration)
      ]);
    } else {
      log('Error, insuffiecent balance, ask the user for balance add');
      throw BalanceException();
    }
  }

  static Future<void> _incrementOnePlayedActivity(String activityID) async {
    final documentReference = FirebaseFirestore.instance.collection("Activites").doc(activityID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentReference);
      final data = snapshot.data();
      int played = data!['played'];
      transaction.set(documentReference, {"played": played + 1}, SetOptions(merge: true));
    });
  }

  static Future<void> _newParticipation(Activity activity, Participations insParticipations) async {
    final documentReference = FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Participations').doc(activity.id);
    late int value;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentReference);
      final data = snapshot.data();
      // if it's the first time the user played this game
      if (data == null) {
        value = 1;
        transaction.set(
            documentReference, {"actName": activity.name, "actAmount": activity.price, 'actType': activity.type, "user_played": value, "actDuration": activity.duration}, SetOptions(merge: true));
// if the user has played the same game previously
      } else {
        value = data['user_played'] + 1;

        transaction.set(documentReference, {"user_played": value}, SetOptions(merge: true));
      }
    });
    insParticipations.addParticipation(activity, value);
  }

  static Future<void> _switchEngagement(int duration) async {
    await FirebaseFirestore.instance.collection("User_Engaged").doc(FirebaseAuth.instance.currentUser!.uid).update({"engaged": true});
    Future.delayed(Duration(minutes: duration), () {
      FirebaseFirestore.instance.collection("User_Engaged").doc(FirebaseAuth.instance.currentUser!.uid).update({"engaged": false});
    });
  }

  static Future<void> _newTransaction(Activity activity, Transactions transactions) async {
    final response = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Transactions")
        .add({"actName": activity.name, "actAmount": activity.price, "transaction_date": Timestamp.now(), 'actType': activity.type, "actIMG": activity.img, "actDuration": activity.duration});
    transactions.addTransaction(activity, response.id);
  }
}
