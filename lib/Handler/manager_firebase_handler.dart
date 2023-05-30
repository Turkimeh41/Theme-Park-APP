import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_user.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/Model/activity.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerFirebaseHandler {
  static Future<void> setLastLogin() async {
    await FirebaseFirestore.instance.collection("Managers").doc(FirebaseAuth.instance.currentUser!.uid).set({"last_login": Timestamp.now()}, SetOptions(merge: true));
  }

  static Future<void> attemptUserPayment(String userID, Activites insActivites, Manager manager, {String? label, String? anonymousID}) async {
    final documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(userID).get();
    final data = documentSnapshot.data();
    if (insActivites.selectedActivity.price <= data!['balance']) {
      //deduce balance
      await _deduceUserBalance(userID, data['balance'], insActivites.selectedActivity.price);
      //new transaction for that user
      await _newUserTransaction(insActivites.selectedActivity, userID);
      //new participation for that user
      await _newUserParticipation(insActivites.selectedActivity.id, userID);
      //increment how many times played 1
      await _incrementOnePlayedActivity(insActivites.selectedActivity.id);
      //turn user engaged, to engagement screen
      await _turnUserEngagement(userID, insActivites.selectedActivity.id);
      //add him to the list of current users
      await _addCurrentUsersToActivity(insActivites, userID, "user");
      //new manager transaction
      await _newManagerTransaction(manager, userID, insActivites.selectedActivity);
    } else {
      throw BalanceException();
    }
  }

  static Future<void> attemptAnonyPayment(String anonyID, Activites insActivites, Manager manager) async {
    final documentSnapshot = await FirebaseFirestore.instance.collection("Anonymous_Users").doc(anonyID).get();
    Map<String, dynamic> anonyData = documentSnapshot.data()!;
    if (anonyData['providerAccountID'] != null) {
      final String userID = anonyData['providerAccountID'];
      final documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(userID).get();
      final data = documentSnapshot.data();
      if (insActivites.selectedActivity.price <= data!['balance']) {
        //deduce balance
        await _deduceUserBalance(userID, data['balance'], insActivites.selectedActivity.price);
        //new transaction for that user
        await _newUserTransaction(insActivites.selectedActivity, userID, label: anonyData['label'], anonyID: anonyID);
        //increment 1 played activity
        await _incrementOnePlayedActivity(insActivites.selectedActivity.id);
        //add the anonymous user to the list
        await _addCurrentUsersToActivity(insActivites, anonyID, "anonymous");
        // new manager transaction
        await _newManagerTransaction(manager, userID, insActivites.selectedActivity);
      } else {
        throw BalanceException();
      }
    } else {
      final anonyData = documentSnapshot.data();
      if (insActivites.selectedActivity.price <= anonyData!['balance']) {
        //deduce balance
        await _deduceAnonyBalance(anonyID, anonyData['balance'], insActivites.selectedActivity.price);
        //increment 1 played activity
        await _incrementOnePlayedActivity(insActivites.selectedActivity.id);
        //add the anonymous user to the list
        await _addCurrentUsersToActivity(insActivites, anonyID, "anonymous");
        // new manager transaction
        await _newManagerTransaction(manager, anonyID, insActivites.selectedActivity);
      } else {
        throw BalanceException();
      }
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

  static Future<void> _deduceAnonyBalance(String anonyID, double anonyBalance, double activityAmount) async {
    double newBalance = anonyBalance - activityAmount;
    await FirebaseFirestore.instance.collection('Anonymous_Users').doc(anonyID).update({"balance": newBalance});
  }

  static Future<void> _addCurrentUsersToActivity(Activites insActivites, String id, String type) async {
    switch (type) {
      case "user":
        final docSnapshot = await FirebaseFirestore.instance.collection("Users").doc(id).get();
        final data = docSnapshot.data();
        await FirebaseFirestore.instance
            .collection("Activites")
            .doc(insActivites.selectedActivity.id)
            .collection("Current_Users")
            .doc(id)
            .set({"username": data!['username'], "first_name": data['first_name'], "last_name": data['last_name'], "imgURL": data['imgURL']});
        insActivites.addCurrentUser(id: id, username: data['username'], first_name: data['first_name'], last_name: data['last_name'], imgURL: data['imgURL']);
        break;
      case "anonymous":
        final docSnapshot = await FirebaseFirestore.instance.collection("Anonymous_Users").doc(id).get();
        final data = docSnapshot.data();
        await FirebaseFirestore.instance.collection("Activites").doc(insActivites.selectedActivity.id).collection("Current_Users").doc().set({"label": data!['label']});
        insActivites.addCurrentUser(id: id, label: data['label']);
        break;
    }
  }

  static Future<void> _deduceUserBalance(String userID, double balance, double activityAmount) async {
    double newBalance = balance = activityAmount;
    await FirebaseFirestore.instance.collection("Users").doc(userID).update({"balance": newBalance});
  }

  static Future<int> _newUserParticipation(String activityID, String userID) async {
    final documentReference = FirebaseFirestore.instance.collection('Users').doc(userID).collection('Participations').doc(activityID);
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

    return value;
  }

  static Future<void> _turnUserEngagement(String userID, String activityID) async {
    await FirebaseFirestore.instance.collection("User_Engaged").doc(userID).update({"engaged": true, "activityID": activityID});
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

  static Future<void> _newManagerTransaction(Manager manager, String id, Activity activity) async {
    final response = await FirebaseFirestore.instance.collection("Managers").doc(FirebaseAuth.instance.currentUser!.uid).collection("Transactions").add({
      "actName": activity.name,
      "actID": activity.id,
      "userID": id,
      "date": Timestamp.now(),
      "actIMG": activity.img,
      "actAmount": activity.price,
    });
    String transactionID = response.id;
    manager.addTransaction(id, activity, transactionID);
  }

  static Future<void> assignAnonyQRCODE(AnonymousUsers insAnonymous, AnonymousUser anonymous, String label, String type, double? balance) async {
    final timestamp = Timestamp.now();
    switch (type) {
      case "provider":
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
            .set({'label': label, "providerAccountID": insAnonymous.currentUserID, "assignedDate": timestamp, "balance": null}, SetOptions(merge: true));

        insAnonymous.userAnonymousLength = (insAnonymous.userAnonymousLength! + 1);
        break;

      case "normal":
        await FirebaseFirestore.instance
            .collection("Anonymous_Users")
            .doc(anonymous.id)
            .set({"balance": balance, "label": label, "assignedDate": timestamp, "providerAccountID": null}, SetOptions(merge: true));
        break;
    }
    insAnonymous.removeByID(anonymous.id);
  }
}
