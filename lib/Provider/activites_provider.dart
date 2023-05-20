// ignore_for_file: unused_import

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chalkdart/chalk_x11.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/activity.dart';
import 'package:chalkdart/chalk.dart';

class Activites with ChangeNotifier {
  List<Activity> _activites = [];

  List<Activity> get activites {
    return [..._activites];
  }

  Future<void> fetchActivites() async {
    final List<Activity> loadedActivites = [];
    log(chalk.aqua.bold('fetching activites...'));
    final documentReference = await FirebaseFirestore.instance.collection('Activites').orderBy('name').get();
    final activityDoc = documentReference.docs;
    if (documentReference.size == 0) {
      log(chalk.red.bold('no activites...'));
      return;
    }
    late Map<String, dynamic> data;
    for (int i = 0; i < documentReference.docs.length; i++) {
      data = activityDoc[i].data();
      loadedActivites.add(Activity(
          img: data['img_link'],
          id: activityDoc[i].id,
          name: data['name'],
          price: data['price'].runtimeType == int ? data['price'].toDouble() : data['price'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          duration: data['duration'],
          type: data['type']));
    }

    _activites = loadedActivites;
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
}
