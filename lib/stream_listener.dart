import 'package:final_project/Engaging/engage_screen.dart';
import 'package:final_project/Main_Menu/mainmenu_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamListener extends StatelessWidget {
  const StreamListener({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('User_Status').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data!['engaged'] == false) {
          return const MainMenuScreen();
        } else if (snapshot.data!['engaged'] == true) {
          return const EngagingScreen();
        }
        return const MainMenuScreen();
      },
    ));
  }
}
