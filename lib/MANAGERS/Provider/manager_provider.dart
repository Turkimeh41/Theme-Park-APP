// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:chalkdart/chalk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Model/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project/Model/manager_transaction.dart' as t;

class Manager {
  late String username;
  late String first_name;
  late String last_name;
  late String email;
  late String phone;
  late String? imgURL;
  late DateTime added;
  final firestore = FirebaseFirestore.instance;
  List<t.Transaction> _proceedTransactions = [];

  List<t.Transaction> get transactions {
    return [..._proceedTransactions];
  }

  Future<void> setManager() async {
    log(chalk.cyan.bold('fetching, and setting manager up...'));
    final documentSnapshot = await firestore.collection("Managers").doc(FirebaseAuth.instance.currentUser!.uid).get();
    final dataMap = documentSnapshot.data();
    username = dataMap!['username'];
    log(chalk.cyan.bold(username));
    first_name = dataMap['first_name'];
    log(chalk.cyan.bold(first_name));
    last_name = dataMap['last_name'];
    log(chalk.cyan.bold(last_name));
    phone = dataMap['phone'];
    log(chalk.cyan.bold(phone));
    imgURL = dataMap['imgURL'];
    log(chalk.cyan.bold(imgURL));
    email = dataMap['email'];
    log(chalk.cyan.bold(email));

    added = (dataMap['added'] as Timestamp).toDate();
    log(chalk.cyan.bold('manager fetched!'));
    log(chalk.cyan.bold('fetching manager transactions..!'));
    final queryDocumentSnapshot = await firestore.collection("Managers").doc(FirebaseAuth.instance.currentUser!.uid).collection('Transactions').get();
    if (queryDocumentSnapshot.size == 0) {
      log(chalk.red.bold('Manager transactions are empty!'));
      return;
    }
    final managerDocSnapshot = queryDocumentSnapshot.docs;
    late Map<String, dynamic> data;
    final List<t.Transaction> loadedTransaction = [];
    for (int i = 0; i < managerDocSnapshot.length; i++) {
      data = managerDocSnapshot[i].data();
      String transID = managerDocSnapshot[i].id;
      String userID = data['userID'];
      String actID = data['actID'];
      String actName = data['actName'];
      String actIMG = data['actIMG'];
      double amount = data['actAmount'] == int ? data['actAmount'].toDouble() : data['actAmount'];
      DateTime transaction_date = (data['date'] as Timestamp).toDate();
      loadedTransaction.add(t.Transaction(id: transID, actID: actID, uID: userID, actName: actName, transaction_date: transaction_date, actIMG: actIMG, actAmount: amount));
    }
    _proceedTransactions = loadedTransaction;
  }

  void addTransaction(String userID, Activity activity, String transactionID) {
    _proceedTransactions
        .add(t.Transaction(id: transactionID, actID: activity.id, uID: userID, actName: activity.name, transaction_date: DateTime.now(), actIMG: activity.img, actAmount: activity.price));
  }
}
