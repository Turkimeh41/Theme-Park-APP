import 'dart:developer';

import 'package:chalkdart/chalk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Handler/firebase_handler.dart';
import 'package:final_project/Model/activity.dart';
import 'package:final_project/Model/participation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Participations with ChangeNotifier {
  List<Participation> _participations = [];

  List<Participation> get participations {
    return [..._participations];
  }

  Future<void> addParticipation(Activity activity) async {
    //add to database
    int played = await FirebaseHandler.newParticipation(activity);

//add it in the list as runtime

//that means the user has played this game for the first time!
    if (played == 1) {
      _participations.add(Participation(activityID: activity.id, actName: activity.name, actDuration: activity.duration, actType: activity.type, actAmount: activity.price, userPlayed: played));
    } else {
      for (int i = 0; i < _participations.length; i++) {
        if (_participations[i].activityID == activity.id) {
          _participations[i].userPlayed += 1;
        }
      }
    }
    notifyListeners();
  }

  Future<void> fetchParticipations() async {
    final List<Participation> loadedParticipations = [];
    final querySnapshot = await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).collection("Participations").get();
    if (querySnapshot.docs.isEmpty) {
      log(chalk.red.bold('no participations...'));
      return;
    }
    final docList = querySnapshot.docs;
    Map<String, dynamic> data;
    String id;
    for (int i = 0; i < docList.length; i++) {
      data = docList[i].data();
      id = docList[i].id;
      loadedParticipations
          .add(Participation(activityID: id, actName: data["actName"], actDuration: data["actDuration"], actType: data["actType"], actAmount: data["actAmount"], userPlayed: data["user_played"]));
    }

    _participations = loadedParticipations;
  }
}
