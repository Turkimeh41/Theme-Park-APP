import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Participations with ChangeNotifier {
  Future<void> newParticipation(String actvID) async {
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
