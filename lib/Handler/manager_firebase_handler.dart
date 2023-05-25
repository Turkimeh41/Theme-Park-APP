import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_user.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/Model/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerFirebaseHandler {
  static Future<void> setLastLogin() async {
    await FirebaseFirestore.instance.collection("Managers").doc(FirebaseAuth.instance.currentUser!.uid).set({"last_login": Timestamp.now()}, SetOptions(merge: true));
  }

  static Future<void> attemptUserPayment(String userID, Activity activity, Manager manager, {String? label, String? anonymousID}) async {
    final documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(userID).get();
    final data = documentSnapshot.data();
    if (activity.price <= data!['balance']) {
      final newBalance = data['balance'] - activity.price;
      await _deduceUserBalance(userID, newBalance);
      await _newUserTransaction(activity, userID);

      await _newUserParticipation(activity, userID);
      await _incrementOnePlayedActivity(activity.id);
      await _switchUserEngagement(userID, true);
      Timer(Duration(minutes: activity.duration), () {
        _switchUserEngagement(userID, false);
      });
    } else {
      throw BalanceException();
    }
  }

  static Future<void> attemptAnonyPayment(String anonyID, Activity activity, Manager manager) async {
    final documentSnapshot = await FirebaseFirestore.instance.collection("Anonymous_Users").doc(anonyID).get();
    Map<String, dynamic> anonyData = documentSnapshot.data()!;
    if (anonyData['providerAccountID'] != null) {
      final String userID = anonyData['providerAccountID'];
      final documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(userID).get();
      final data = documentSnapshot.data();
      if (activity.price <= data!['balance']) {
        final newBalance = data['balance'] - activity.price;
        await _deduceUserBalance(userID, newBalance);
        await _newUserTransaction(activity, userID, label: anonyData['label'], anonyID: anonyID);
        await _incrementOnePlayedActivity(activity.id);
      } else {
        throw BalanceException();
      }
    } else {
//if the anony has a balance of his own we handle it here
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

  static Future<void> _deduceUserBalance(String userID, double balance) async {
    await FirebaseFirestore.instance.collection("Users").doc(userID).update({"balance": balance});
  }

  static Future<int> _newUserParticipation(Activity activity, String userID) async {
    final documentReference = FirebaseFirestore.instance.collection('Users').doc(userID).collection('Participations').doc(activity.id);
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

    return value;
  }

  static Future<void> _switchUserEngagement(String userID, bool status) async {
    await FirebaseFirestore.instance.collection("User_Engaged").doc(userID).update({"engaged": status});
  }

  static Future<String> _newUserTransaction(Activity activity, String userID, {String? anonyID, String? label}) async {
    final response = await FirebaseFirestore.instance.collection("Users").doc(userID).collection("Transactions").add({
      "actName": activity.name,
      "actAmount": activity.price,
      "transaction_date": Timestamp.now(),
      'actType': activity.type,
      "actIMG": activity.img,
      "actDuration": activity.duration,
      "anonyID": anonyID,
      "label": label
    });
    return response.id;
  }

  static Future<void> _newManagerTransaction(Manager manager, String userID, Activity activity) async {
    final response = await FirebaseFirestore.instance.collection("Managers").doc(FirebaseAuth.instance.currentUser!.uid).collection("Transactions").add({
      "actName": activity.name,
      "actID": activity.id,
      "userID": userID,
      "date": Timestamp.now(),
      "actIMG": activity.img,
    });
    String transactionID = response.id;
    manager.addTransaction(userID, activity, transactionID);
  }

  static Future<void> assignAnonyQRCODEtoProviderID(AnonymousUsers insAnonymous, AnonymousUser anonymous, String label) async {
    final timestamp = Timestamp.now();
    //register a new anonymous QR CODE to the user, maximum should be 3, and checked in the front end!!
    FirebaseFirestore.instance
        .collection('Users')
        .doc(insAnonymous.currentUserID)
        .collection("Anonymous_Users")
        .doc(anonymous.id)
        .set({"label": label, "assignedDate": timestamp, 'qrURL': anonymous.qrURL});
    //update the existing QR CODE from being availaible to being assigned an anonymous User
    FirebaseFirestore.instance
        .collection("Anonymous_Users")
        .doc(anonymous.id)
        .set({'label': label, "providerAccountID": insAnonymous.currentUserID, "assignedDate": timestamp}, SetOptions(merge: true));

    insAnonymous.userAnonymousLength = (insAnonymous.userAnonymousLength! + 1);
    insAnonymous.removeByID(anonymous.id);
  }
}
