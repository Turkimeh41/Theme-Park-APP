import 'dart:developer';

import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

bool _loading = false;

class _MainMenuScreenState extends State<MainMenuScreen> {
  Future<String> _data() async {
    final storage = FirebaseStorage.instance;
    final refList = await storage.ref('qr-codes/users/${FirebaseAuth.instance.currentUser!.uid}').listAll();
    final ref = refList.items.first;

    final link = await ref.getDownloadURL();
    return link;
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder(
          future: _data(),
          builder: (context, snapshot) {
            return SizedBox(
              height: dh,
              width: dw,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          _loading = false;
                        });
                        Get.off(() => const LoginScreen());
                      },
                      child: !_loading ? const Text('Log out') : const CircularProgressIndicator()),
                  ElevatedButton(
                    child: const Text('Press me'),
                    onPressed: () async {
                      log('adding...');
                      final response = await FirebaseFunctions.instanceFor(region: "europe-west1")
                          .httpsCallable('addActivity')
                          .call({'name': 'RollerCoaster', 'price': '30', 'duration': '15', 'description': 'a very nice game'});
                      response.data['success'];
                      log('Success...');
                    },
                  ),
                  CachedNetworkImage(
                    imageUrl: snapshot.data!,
                    placeholder: (context, url) => CircularProgressIndicator(),
                  ),
                  ElevatedButton(
                    child: const Text('Press me'),
                    onPressed: () async {},
                  ),
                ],
              ),
            );
          }),
    );
  }
}
