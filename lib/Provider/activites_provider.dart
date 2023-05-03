// ignore_for_file: unused_import

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/activity.dart';

class Activites with ChangeNotifier {
  List<Activity> _activites = [];

  List<Activity> get activites {
    return [..._activites];
  }

  Future<void> fetchActivites() async {
    log('fetching activity');
    final List<Activity> loadedActivites = [];

    final documentReference = await FirebaseFirestore.instance.collection('Activites').orderBy('name').get();
    final activityDoc = documentReference.docs;
    if (documentReference.size == 0) {
      return;
    }
    for (int i = 0; i < documentReference.docs.length; i++) {
      loadedActivites.add(Activity(
          activityDoc[i]['name'], activityDoc[i]['price'], (activityDoc[i]['createdAt'] as Timestamp).toDate(), activityDoc[i]['description'], activityDoc[i]['duration'], activityDoc[i]['type']));
    }

    _activites = loadedActivites;
  }
}
