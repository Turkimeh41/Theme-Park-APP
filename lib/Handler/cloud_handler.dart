// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:final_project/Exception/balance_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//This is the instance of my firebase cloud functions object, which has all the functions i've created
final function = FirebaseFunctions.instanceFor(region: "europe-west1");

class CloudHandler {
  static Future<String> sendSMSTwilio(String phone) async {
    final response = await function.httpsCallable('sendSMSTwilio').call({'phone_number': "+966${phone.replaceAll(RegExp(r"\s+\b|\b\s"), '')}"});
    return response.data['smscode'];
  }

  static Future<void> userExists(String username, String email, String phone) async {
    await function.httpsCallable('existsUser').call({'username': username, 'emailAddress': email, 'number': phone});
  }

  static Future<Map<String, dynamic>> addUser(String username, String password, String firstName, String lastName, String email, String phone, int gender) async {
    final response = await function
        .httpsCallable('addUser')
        .call({'username': username, 'password': password, 'first_name': firstName, 'last_name': lastName, 'emailAddress': email, 'gender': gender, 'number': phone});

    return {'token': response.data['token']};
  }

  static Future<String> loginUser(String username, String password) async {
    final result = await function.httpsCallable('loginUser').call({'username': username, 'password': password});
    return result.data['token'];
  }

  static Future<void> loginToken(String token) async {
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }


  static Future<void> rechargeBalance(double amount) async {
    final documentReference = FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentReference);
      final currentBalance = snapshot.data()!['balance'];
      transaction.update(documentReference, {'balance': currentBalance + amount});
    });
  }

  static Future<void> attemptPayment(String prefix_ActvID) async {
    log('fetching secret keys...');
    log('fetched!');
    log('decrypting...');

    log('fetching user, and activity docs, to check balance and update it...');
    final results = await Future.wait(
        [FirebaseFirestore.instance.collection('Activites').doc(prefix_ActvID.substring(5)).get(), FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get()]);
    log('fetched!');
    final actvResult = results[0].data();
    final userResult = results[1].data();
    if (actvResult!['price'] < userResult!['balance']) {
      log('deducing balance...');
      final newBalance = userResult['balance'] - actvResult['price'];
      FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update({'balance': newBalance});
      if (actvResult["played"] != null) {
        int value = actvResult["played"];
        FirebaseFirestore.instance.collection("Activites").doc(prefix_ActvID.substring(5)).set({"played": value + 1}, SetOptions(merge: true));
      } else {
        FirebaseFirestore.instance.collection("Activites").doc(prefix_ActvID.substring(5)).set({"played": 0}, SetOptions(merge: true));
      }
          log('done!');
    }
    //we throw our own error exception which is an object instantiation, we could catch this error, and workaround that in our widget to make user add balance
    else if (actvResult['price'] > userResult['balance']) {
      log('not enough balance...');
      throw BalanceException();
    }

  }

  static Future<void> newParticipation(String actvID) async {
    final documentReference = FirebaseFirestore.instance.collection('Participations').doc(FirebaseAuth.instance.currentUser!.uid).collection('Activites_Participants').doc(actvID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentReference);
      final int value;
      final data = snapshot.data();
      if (data == null) {
        value = 0;
      } else {
        value = data['user_participations'];
      }
      transaction.set(documentReference, {'user_participations': value + 1} /* ,SetOptions(merge: true) */);
    });
  }
}
