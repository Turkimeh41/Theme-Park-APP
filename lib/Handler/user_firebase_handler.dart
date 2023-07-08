// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Model/activity.dart';
import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:final_project/USERS/Provider/transactions_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/USERS/Provider/user_provider.dart' as u;

//This is the instance of my firebase cloud functions object, which has all the functions i've created
final function = FirebaseFunctions.instanceFor(region: "europe-west1");

class UserFirebaseHandler {
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

  static Future<void> sendMessage(u.User user, String message, String activityID) async {
    await FirebaseFirestore.instance.collection("Activites").doc(activityID).collection("Chat").add({"message": message, "userID": FirebaseAuth.instance.currentUser!.uid});
  }

  static Future<void> setLastLogin() async {
    await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).set({"last_login": Timestamp.now()}, SetOptions(merge: true));
  }

  static Future<void> _deduceBalance(String userID, double balance, double activityAmount) async {
    double newBalance = balance - activityAmount;
    await FirebaseFirestore.instance.collection("Users").doc(userID).update({"balance": newBalance});
  }

  static Future<void> attemptPayment(Activity activity, u.User user, Participations insParticipations, Transactions insTransactions, ActivityEngagement insEngagement) async {
    if (user.balance >= activity.price) {
      await Future.wait([
        _deduceBalance(FirebaseAuth.instance.currentUser!.uid, user.balance, activity.price),
        _incrementOnePlayedActivity(activity.id),
        _newParticipation(activity.id, insParticipations),
        _newTransaction(activity, insTransactions),
        _addPoints(user, activity.price),
        _addUserEngagement(user, activity.id)
      ]);
      await _turnEngagement(activity.id);
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

  static Future<void> _addPoints(u.User user, double amount) async {
    int currentPoints = user.points;
    currentPoints += currentPoints + amount.toInt();
    FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update({"points": currentPoints});
    user.points = currentPoints;
  }

  static Future<void> _addUserEngagement(u.User user, String activityID) async {
    await FirebaseFirestore.instance.collection("Activites").doc(activityID).collection("Current_Users").doc(FirebaseAuth.instance.currentUser!.uid).set({
      "username": user.username,
      "imgURL": user.imgURL,
      "first_name": user.first_name,
      "last_name": user.last_name,
    });
  }

  static Future<void> _newParticipation(String activityID, Participations insParticipations) async {
    final documentReference = FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Participations').doc(activityID);
    late int value;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentReference);
      final data = snapshot.data();
      // if it's the first time the user played this game
      if (data == null) {
        value = 1;
        transaction.set(documentReference, {"user_played": value}, SetOptions(merge: true));
// if the user has played the same game previously
      } else {
        value = data['user_played'] + 1;

        transaction.set(documentReference, {"user_played": value}, SetOptions(merge: true));
      }
    });
    insParticipations.addParticipation(activityID, value);
  }

  static Future<void> _turnEngagement(String activityID) async {
    await FirebaseFirestore.instance.collection("User_Engaged").doc(FirebaseAuth.instance.currentUser!.uid).update({"engaged": true, "activityID": activityID});
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
