import 'dart:developer';

import 'package:chalkdart/chalk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_user.dart';
import 'package:flutter/material.dart';

class AnonymousUsers with ChangeNotifier {
  List<AnonymousUser> _anonymousUsers = [];
  bool confirm = false;
  List<AnonymousUser> get anonymousUsers {
    return [..._anonymousUsers];
  }

  String? currentUserID;
  int? userAnonymousLength;
  Future<void> fetchAnonymousUnassignedQR() async {
    final List<AnonymousUser> loadedAnonymousUsers = [];
    await Future.delayed(const Duration(milliseconds: 400));
    final response = await FirebaseFirestore.instance.collection("Anonymous_Users").where("label", isNull: true).get();
    if (response.size == 0) {
      log(chalk.red.bold('THERES NO QR CODES THAT ARE AVAILIABLE, ask the admin to generate new ones!'));
      return;
    }
    final querySnapshotList = response.docs;
    for (int i = 0; i < querySnapshotList.length; i++) {
      final id = querySnapshotList[i].id;
      final data = querySnapshotList[i].data();
      final qrURL = data['qrURL'];
      loadedAnonymousUsers.add(AnonymousUser(id: id, assignedDate: null, qrURL: qrURL, providerAccountID: null, label: null));
    }
    _anonymousUsers = loadedAnonymousUsers;
  }

  void removeByID(String anonyID) {
    for (int i = 0; i < _anonymousUsers.length; i++) {
      if (_anonymousUsers[i].id == anonyID) {
        _anonymousUsers.removeAt(i);
        break;
      }
    }
    notifyListeners();
  }

  Future<void> setCurrentUser(String userID) async {
    currentUserID = userID;
    final response = await FirebaseFirestore.instance.collection("Users").doc(currentUserID).collection("Anonymous_Users").get();
    final docsProivderAnonySnapshot = response;
    if (docsProivderAnonySnapshot.size == 0) {
      userAnonymousLength = 0;
    } else {
      userAnonymousLength = docsProivderAnonySnapshot.size;
    }
    confirm = true;
    notifyListeners();
  }
}
