import 'package:final_project/USERS/ENGAGING/initial_screen.dart';
import 'package:final_project/USERS/MAIN_MENU/tab_screen.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class StreamListener extends StatefulWidget {
  const StreamListener({super.key});

  @override
  State<StreamListener> createState() => _StreamListenerState();
}

class _StreamListenerState extends State<StreamListener> {
  @override
  Widget build(BuildContext context) {
    final insEngagement = Provider.of<ActivityEngagement>(context, listen: false);
    final insActivites = Provider.of<Activites>(context, listen: false);
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('User_Engaged').doc(auth.FirebaseAuth.instance.currentUser!.uid).snapshots(),
      builder: (builderContext, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          );
        } else if (snapshot.data!['engaged'] == true) {
          insEngagement.currentActivity = insActivites.getActivityByID(snapshot.data!['activityID']);
          return const InitialScreen();
        } else {
          Get.back();
          insEngagement.reset();
          return const TabScreen();
        }
      },
    );
  }
}
