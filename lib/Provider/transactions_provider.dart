import 'dart:developer';
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
    log('fetching transactions..');
    List<Transaction> loadedTransactions = [];
    final documentReferenceTransactions =
        await firestore.FirebaseFirestore.instance.collection("Transactions").doc(FirebaseAuth.instance.currentUser!.uid).collection('User_Transactions').orderBy('Transaction_date').get();
    if (documentReferenceTransactions.size == 0) {
      return;
    }
    final transactionDocs = documentReferenceTransactions.docs;
    for (int i = 0; i < transactionDocs.length; i++) {
      loadedTransactions.add(Transaction(transactionDocs[i].id, transactionDocs[i]['actID'], transactionDocs[i]['actName'], (transactionDocs[i]['date'] as firestore.Timestamp).toDate(),
          transactionDocs[i]['amount'], transactionDocs[i]['type']));
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
    _userTransactions.add(Transaction(response.id, documentReferenceActivites.id, documentReferenceActivites['name'], (documentReferenceActivites['date'] as firestore.Timestamp).toDate(),
        documentReferenceActivites['price'], documentReferenceActivites['type']));
  }
}
