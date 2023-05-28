// ignore_for_file: unused_element

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Model/activity.dart';
import 'package:final_project/Model/current_user_model.dart';
import 'package:flutter/material.dart';

class ActivityEngagement with ChangeNotifier {
  StreamSubscription? usersSubscription;
  StreamSubscription? messageSubscription;
  List<CurrentUser> _currentusers = [];
  bool initialStream = true;
  Activity? currentActivity;
  List<CurrentUser> get currentusers {
    return [..._currentusers];
  }

  void initializeUsersStream() {
    log('initiliazing users stream');
    usersSubscription = FirebaseFirestore.instance.collection("Activites").doc(currentActivity!.id).collection("Current_Users").snapshots().listen((event) {
      if (initialStream) {
        final List<CurrentUser> loadedUsers = [];
        final documentSnapshot = event.docChanges;
        for (int i = 0; i < documentSnapshot.length; i++) {
          final id = documentSnapshot[i].doc.id;
          final data = documentSnapshot[i].doc.data();
          bool validation = _checkIfUserExists(id);
          log('validation for ID: $id is $validation');
          if (validation) {
            loadedUsers.add(CurrentUser(
                id: id, label: data!['label'], imgURL: data['imgURL'], username: data['username'], first_name: data['first_name'], last_name: data['last_name'], valueNotifier: ValueNotifier('')));
          }
        }
        _currentusers = loadedUsers;

        _initializeMessageStream();
        initialStream = !initialStream;
      } else {
        final documentSnapshot = event.docChanges;
        for (int i = 0; i < documentSnapshot.length; i++) {
          final id = documentSnapshot[i].doc.id;
          final data = documentSnapshot[i].doc.data();
          bool validation = _checkIfUserExists(id);
          if (validation) {
            _currentusers.add(CurrentUser(
                id: id, label: data!['label'], imgURL: data['imgURL'], username: data['username'], first_name: data['first_name'], last_name: data['last_name'], valueNotifier: ValueNotifier('')));
          }
        }
      }
      notifyListeners();
    });
  }

  void _initializeMessageStream() {
    log('done and starting messageStream');
    messageSubscription = FirebaseFirestore.instance.collection("Activites").doc(currentActivity!.id).collection("Chat").snapshots().listen((event) {
      final userData = event.docChanges.last.doc.data();
      _notifiyWidgetMessage(userData!['message'], _getUserByID(userData['userID']));
    });
  }

  void _notifiyWidgetMessage(String message, CurrentUser user) {
    user.valueNotifier!.value = '';
    Future.delayed(const Duration(milliseconds: 20), () {
      user.valueNotifier!.value = message;
    });
  }

  CurrentUser _getUserByID(String id) {
    for (int i = 0; i < _currentusers.length; i++) {
      if (id == _currentusers[i].id) {
        return _currentusers[i];
      }
    }

    throw Exception('User cannot be found!');
  }

  void reset() {
    initialStream = true;
    if (usersSubscription != null) {
      usersSubscription!.cancel();
      messageSubscription!.cancel();
    }
  }

  bool _checkIfUserExists(String id) {
    for (int i = 0; i < _currentusers.length; i++) {
      if (id == _currentusers[i].id) {
        return false;
      }
    }
    return true;
  }
}
