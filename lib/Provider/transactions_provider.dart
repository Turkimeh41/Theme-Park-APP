import 'dart:developer';
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
    log(chalk.green.bold('fetching transactions..'));
    List<Transaction> loadedTransactions = [];
    final documentReferenceTransactions =
        await firestore.FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).collection('Transactions').orderBy('transaction_date', descending: true).get();
    if (documentReferenceTransactions.size == 0) {
      log(chalk.red.bold('no transactions...'));
      return;
    }
    final transactionDocs = documentReferenceTransactions.docs;
    late Map<String, dynamic> data;
    for (int i = 0; i < transactionDocs.length; i++) {
      data = transactionDocs[i].data();
      loadedTransactions.add(Transaction(
          anonymousID: data['anonyID'],
          label: data['label'],
          transID: transactionDocs[i].id,
          actIMG: data["actIMG"],
          actName: data["actName"],
          transaction_date: (data["transaction_date"] as firestore.Timestamp).toDate(),
          actAmount: data["actAmount"] is int ? data['actAmount'].toDouble() : data['actAmount'],
          actType: data["actType"],
          actDuration: data["actDuration"]));
    }

    _userTransactions = loadedTransactions;
    log(chalk.green.bold('fetching transactions..'));
    notifyListeners();
  }

  List<Transaction> filter(bool ascending, String search) {
    final filteredTransactions = _userTransactions.where((element) => element.actName.toLowerCase().startsWith(search.toLowerCase())).toList();

    if (ascending) {
      filteredTransactions.sort((a, b) => a.transaction_date.compareTo(b.transaction_date));
    } else {
      filteredTransactions.sort((a, b) => b.transaction_date.compareTo(a.transaction_date));
    }

    return filteredTransactions;
  }

  void addTransaction(Activity activity, String transID) async {
//reflect the new transaction in runtime
    _userTransactions.add(Transaction(
        transID: transID, actName: activity.name, transaction_date: DateTime.now(), actIMG: activity.img, actAmount: activity.price, actType: activity.type, actDuration: activity.duration));
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

  double get totalExpenses {
    double total = 0;
    for (var transaction in _userTransactions) {
      total += transaction.actAmount;
    }
    return total;
  }

  List<double> getExpensesANDtransactionsByAnonymousID(String label) {
    double total = 0;
    double transactions = 0;
    for (var transaction in _userTransactions) {
      if (transaction.label == label) {
        total += transaction.actAmount;
        transactions++;
      }
    }
    return [total, transactions];
  }
}
