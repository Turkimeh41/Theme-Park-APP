import 'dart:developer';
import 'package:final_project/Handler/firebase_handler.dart';
import 'package:final_project/Model/activity.dart';
import 'package:flutter/material.dart';

import '../Model/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:chalkdart/chalk.dart';

class Transactions with ChangeNotifier {
  List<Transaction> _userTransactions = [];

  List<Transaction> get transactions {
    return [..._userTransactions];
  }

  Future<void> fetchTransactions() async {
    log('fetching transactions..');
    List<Transaction> loadedTransactions = [];
    final documentReferenceTransactions =
        await firestore.FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).collection('Transactions').orderBy('transaction_date').get();
    if (documentReferenceTransactions.size == 0) {
      log('no transactions...');
      return;
    }
    final transactionDocs = documentReferenceTransactions.docs;
    late Map<String, dynamic> data;
    for (int i = 0; i < transactionDocs.length; i++) {
      data = transactionDocs[i].data();
      loadedTransactions.add(Transaction(
          transID: transactionDocs[i].id,
          actName: data["actName"],
          transaction_date: (data["transaction_date"] as firestore.Timestamp).toDate(),
          actAmount: data["actAmount"],
          actType: data["actType"],
          actDuration: data["actDuration"]));
    }

    _userTransactions = loadedTransactions;
    log('fetched transations!');
  }

  Future<void> addTransaction(Activity activity) async {
    //add the transaction of the user inside the database
    final transID = await FirebaseHandler.newTransaction(activity);

//reflect the new transaction in runtime
    _userTransactions.add(Transaction(transID: transID, actName: activity.name, transaction_date: DateTime.now(), actAmount: activity.price, actType: activity.type, actDuration: activity.duration));
    notifyListeners();
  }

  void printTransactions() {
    log(chalk.yellowBright.bold("=================================================="));

    if (_userTransactions.isEmpty) {
      log(chalk.red.bold('No Transactions have been procceed by the user!'));
      return;
    }
    log(chalk.blue('Printing \$Transactions that of ${_userTransactions.length} length'));
    for (int i = 0; i < _userTransactions.length; i++) {
      log(chalk.green.bold("ID: "));
      log(chalk.green.bold("ActName: ${_userTransactions[i].actName}"));
      log(chalk.green.bold("Date: ${_userTransactions[i].transaction_date.toIso8601String()}"));
      log(chalk.green.bold("Amount: ${_userTransactions[i].actAmount.toString()}"));
      log(chalk.green.bold("Type: ${_userTransactions[i].actType}"));
    }
    log(chalk.yellowBright.bold("=================================================="));
  }
}
