import 'dart:developer';

import 'package:chalkdart/chalk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Model/participation.dart';
import 'package:final_project/USERS/MAIN_MENU/DRAWER/STATISTICS_SCREEN/activity_maxplayed.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Participations with ChangeNotifier {
  List<Participation> _participations = [];

  List<Participation> get participations {
    return [..._participations];
  }

  Future<void> addParticipation(String activityID, int played) async {
    //added to database already by FirebaseHandler static methods

//so now we just have to add it in the runtime
//that means the user has played this game for the first time!
    if (played == 1) {
      _participations.add(Participation(activityID: activityID, userPlayed: played));
    } else {
      for (int i = 0; i < _participations.length; i++) {
        if (_participations[i].activityID == activityID) {
          _participations[i].userPlayed += 1;
        }
      }
    }
    notifyListeners();
  }

  List<ActivityPlayed> getMax6Activites(Activites insActivites) {
    final participations = _participations;
    final List<ActivityPlayed> activityList = [];
    participations.sort((a, b) => a.userPlayed.compareTo(b.userPlayed));
    for (int i = 0; i < participations.length; i++) {
      activityList.add(ActivityPlayed(insActivites.activites.singleWhere((element) => participations[i].activityID == element.id).name, participations[i].userPlayed));
      if (i == 5) {
        break;
      }
    }
    return activityList;
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
      loadedParticipations.add(Participation(activityID: id, userPlayed: data["user_played"]));
    }

    _participations = loadedParticipations;
    notifyListeners();
  }

  int getPlayedCountByID(String activityID) {
    for (var element in _participations) {
      if (element.activityID == activityID) {
        return element.userPlayed;
      }
    }
    throw Exception();
  }

  double getMaxPlayedActivityDivisbleBy10() {
    double max = _participations.first.userPlayed.toDouble();
    for (int i = 1; i < _participations.length; i++) {
      if (_participations[i].userPlayed > max) {
        max = _participations[i].userPlayed.toDouble();
      }
    }
    for (int i = 0; i < double.infinity; i++) {
      if (max % 10 == 0) {
        return max;
      }
      max += 1;
    }
    throw Exception();
  }
}
