import 'dart:developer';
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
        await firestore.FirebaseFirestore.instance.collection("Transactions").doc(FirebaseAuth.instance.currentUser!.uid).collection('User_Transactions').orderBy('Transaction_date').get();
    if (documentReferenceTransactions.size == 0) {
      log('no transactions...');
      return;
    }
    final transactionDocs = documentReferenceTransactions.docs;
    for (int i = 0; i < transactionDocs.length; i++) {
      loadedTransactions.add(Transaction(transactionDocs[i].id, transactionDocs[i].data()['actID'], transactionDocs[i].data()['actName'],
          (transactionDocs[i].data()['date'] as firestore.Timestamp).toDate(), transactionDocs[i].data()['amount'], transactionDocs[i].data()['type']));
    }

    _userTransactions = loadedTransactions;
    log('fetched transations!');
  }

  Future<void> addTransaction(String actvID) async {
    final timestamp = firestore.Timestamp.now();
    final response = await firestore.FirebaseFirestore.instance
        .collection('Transactions')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('User_Transactions')
        .add({'actID': actvID, 'Transaction_date': timestamp});
    final documentReferenceActivites = await firestore.FirebaseFirestore.instance.collection("Activites").doc(actvID).get();
    _userTransactions.add(Transaction(response.id, documentReferenceActivites.id, documentReferenceActivites['name'], (documentReferenceActivites['date'] as firestore.Timestamp).toDate(),
        documentReferenceActivites['price'], documentReferenceActivites['type']));
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
      log(chalk.green.bold("ActName: ${_userTransactions[i].activityName}"));
      log(chalk.green.bold("Date: ${_userTransactions[i].transaction_date.toIso8601String()}"));
      log(chalk.green.bold("Amount: ${_userTransactions[i].amount.toString()}"));
      log(chalk.green.bold("Type: ${_userTransactions[i].type}"));
    }
    log(chalk.yellowBright.bold("=================================================="));
  }
}
