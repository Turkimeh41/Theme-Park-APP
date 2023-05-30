// ignore_for_file: unused_import, non_constant_identifier_names

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chalkdart/chalk_x11.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:final_project/Model/current_user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../Model/activity.dart';
import 'package:chalkdart/chalk.dart';

class Activites with ChangeNotifier {
  List<Activity> _activites = [];

  List<Activity> get activites {
    return [..._activites];
  }

  bool loadingCurrentUsers = false;

  List<CurrentUser> _currentUsers = [];
  late Activity selectedActivity;

  List<CurrentUser> get currentUsers {
    return [..._currentUsers];
  }

  Future<void> fetchActivites() async {
    final List<Activity> loadedActivites = [];
    log(chalk.aqua.bold('Fetching activites...'));
    final futures = await Future.wait([FirebaseFirestore.instance.collection('Activites').get(), FirebaseFirestore.instance.collection('Activity_Started').get()]);
    final activityQuerySnapshot = futures[0];
    final startedQuerySnapshot = futures[1];
    final activityDocs = activityQuerySnapshot.docs;
    final startedDocs = startedQuerySnapshot.docs;
    activityDocs.sort((a, b) => a.id.compareTo(b.id));
    startedDocs.sort((a, b) => a.id.compareTo(b.id));

    if (activityQuerySnapshot.size == 0) {
      log(chalk.red.bold('no activites...'));
      return;
    }

    late Map<String, dynamic> activityData;
    late Map<String, dynamic> startedData;
    for (int i = 0; i < activityQuerySnapshot.docs.length; i++) {
      activityData = activityDocs[i].data();
      startedData = startedDocs[i].data();
      loadedActivites.add(Activity(
        id: activityDocs[i].id,
        seats: activityData['seats'],
        img: activityData['imgURL'],
        name: activityData['name'],
        price: activityData['price'].runtimeType == int ? activityData['price'].toDouble() : activityData['price'],
        createdAt: (activityData['createdAt'] as Timestamp).toDate(),
        duration: activityData['duration'],
        type: activityData['type'],
        started: startedData['started'],
      ));
    }
    _activites = loadedActivites;
    selectedActivity = _activites.first;
    log(chalk.aqua.bold('activites should be saved!'));
  }

  void printActivites() {
    log(chalk.yellowBright.bold("=================================================="));
    if (_activites.isEmpty) {
      log(chalk.red.bold('Theres no Activites'));
      return;
    }
    log(chalk.lightBlue('Printing \$Activites that of ${_activites.length} length'));
    for (int i = 0; i < _activites.length; i++) {
      log(chalk.green.bold("ID: ${_activites[i].id}"));
      log(chalk.green.bold("ActName: ${_activites[i].name}"));
      log(chalk.green.bold("createdAt: ${_activites[i].createdAt.toIso8601String()}"));
      log(chalk.green.bold("price: ${_activites[i].price.toString()}"));
      log(chalk.green.bold("Type: ${_activites[i].type}"));
    }
    log(chalk.yellowBright.bold("=================================================="));
  }

  Activity getActivityByID(String id) {
    final activity = _activites.firstWhere((element) => element.id == id);

    return activity;
  }

  Future<void> preloadImages(BuildContext context) async {
    await Future.wait(_activites.map((activity) => precacheImage(CachedNetworkImageProvider(activity.img), context)));
  }

  Future<void> selectActivity(Activity activity) async {
    selectedActivity = activity;
    loadingCurrentUsers = true;
    notifyListeners();
    await _getCurrentUsersOfActivity();
    loadingCurrentUsers = false;
    notifyListeners();
  }

  Future<void> startActivity() async {
    await FirebaseFirestore.instance.collection("Activity_Started").doc(selectedActivity.id).set({'started': true});
    selectedActivity.started = true;
    notifyListeners();
  }

  Future<void> endActivity() async {
    try {
      // Get a reference to the collection
      final chatRef = FirebaseFirestore.instance.collection('Activites').doc(selectedActivity.id).collection("Chat");

      // Retrieve all documents in the collection
      final snapshot = await chatRef.get();

      // Delete each document one by one
      final deletePromises = snapshot.docs.map((doc) => doc.reference.delete());
      await Future.wait(deletePromises);

      log('Collection removed successfully.');
    } catch (e) {
      log('Error removing collection: $e');
    }
    try {
      // Get a reference to the collection
      final currentUsersRef = FirebaseFirestore.instance.collection('Activites').doc(selectedActivity.id).collection("Current_Users");

      // Retrieve all documents in the collection
      final snapshot = await currentUsersRef.get();

      // Delete each document one by one
      final deletePromises = snapshot.docs.map((document) async {
        final id = document.id;
        final data = document.data();
        await document.reference.delete();
        if (data['username'] != null) {
          await FirebaseFirestore.instance.collection("User_Engaged").doc(id).set({"engaged": false, "activityID": null});
        }
      });
      await Future.wait(deletePromises);
      await FirebaseFirestore.instance.collection("Activity_Started").doc(selectedActivity.id).set({'started': false});
      log('Collection removed successfully.');
    } catch (e) {
      log('Error removing collection: $e');
    }
    _currentUsers = [];
    selectedActivity.started = false;
    notifyListeners();
  }

  Future<void> _getCurrentUsersOfActivity() async {
    List<CurrentUser> loadedCurrentUsers = [];
    final querySnapshot = await FirebaseFirestore.instance.collection("Activites").doc(selectedActivity.id).collection("Current_Users").get();
    if (querySnapshot.size == 0) {
      log(chalk.red.bold('Current Users of the selected Activity is empty!'));
    }
    final documentList = querySnapshot.docs;

    for (int i = 0; i < documentList.length; i++) {
      final id = documentList[i].id;
      final data = documentList[i].data();
      loadedCurrentUsers
          .add(CurrentUser(id: id, imgURL: data['imgURL'], label: data['label'], first_name: data['first_name'], last_name: data['last_name'], username: data['username'], valueNotifier: null));
    }
    _currentUsers = loadedCurrentUsers;
    log(chalk.green.bold('Loaded current users of length: ${_currentUsers.length} into the list!'));
  }

  void addCurrentUser({required String id, String? username, String? first_name, String? last_name, String? label, String? imgURL}) {
    _currentUsers.add(CurrentUser(imgURL: imgURL, id: id, label: label, first_name: first_name, last_name: last_name, username: username, valueNotifier: null));

    notifyListeners();
  }
}
