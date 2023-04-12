import 'package:flutter/material.dart';

import '../Model/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class Transactions with ChangeNotifier {
  List<Transaction> _userTransactions = [];

  List<Transaction> get transactions {
    return [..._userTransactions];
  }

  Future<void> fetchTransactions() async {
    List<Transaction> loadedTransactions = [];
    final documentReferenceTransactions =
        await firestore.FirebaseFirestore.instance.collection("Transactions").doc(FirebaseAuth.instance.currentUser!.uid).collection('User_Transactions').orderBy('Transaction_date').get();
    final documentReferenceActivites = await firestore.FirebaseFirestore.instance.collection("Activites").get();

    final transactionDocs = documentReferenceTransactions.docs;
    //sort the list with ascending order =>
    // transactionDocs.sort((a, b) => (a["Transaction_date"] as firestore.Timestamp).compareTo(b["Transaction_date"]));

    for (int i = 0; i < documentReferenceTransactions.docs.length; i++) {
      final activityDoc = documentReferenceActivites.docs.singleWhere((element) => transactionDocs[i]['actID'] == element.id);
      loadedTransactions
          .add(Transaction(transactionDocs[i].id, activityDoc['name'], (transactionDocs[i]['Transaction_date'] as firestore.Timestamp).toDate(), activityDoc['price'], activityDoc['type']));
    }

    _userTransactions = loadedTransactions;
  }

  Future<void> addTransaction(String actvID) async {
    final timestamp = firestore.Timestamp.now();
    final response = await firestore.FirebaseFirestore.instance
        .collection('Transactions')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('User_Transactions')
        .add({'actID': actvID, 'Transaction_date': timestamp});
    final documentReferenceActivites = await firestore.FirebaseFirestore.instance.collection("Activites").doc(actvID).get();
    _userTransactions.add(Transaction(response.id, documentReferenceActivites['name'], timestamp.toDate(), documentReferenceActivites['price'], documentReferenceActivites['type']));
    notifyListeners();
  }
}
