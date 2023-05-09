// ignore_for_file: non_constant_identifier_names
import 'dart:developer';
import 'dart:io';

import 'package:chalkdart/chalk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class User with ChangeNotifier {
  late final String username;
  late String first_name;
  late String last_name;
  late double balance;
  late final String phone_number;
  late final DateTime registered;
  late final int gender;
  late final String qr_link;
  late String userImg_link;

  Future<void> setUser() async {
    log('setting user');
    final documentReference = await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    username = documentReference['username'];
    first_name = documentReference['first_name'];
    last_name = documentReference['last_name'];
    if (documentReference['balance'] is int) {
      balance = (documentReference['balance'] as int).toDouble();
    } else {
      balance = documentReference['balance'];
    }

    qr_link = documentReference['qr_link'];

    userImg_link = documentReference['imguser_link'];
    phone_number = documentReference['phone_number'];
    registered = (documentReference['registered'] as Timestamp).toDate();
    gender = documentReference['gender'];
    log('user\'s been set');
  }

  Future<void> editPicture(Function(void Function()) setState, String oldLink) async {
    final pick = ImagePicker();
    const uuid = Uuid();
    XFile? image;
    final picked = await pick.pickImage(source: ImageSource.camera, maxHeight: 256, maxWidth: 256);
    if (picked != null && picked.path.isNotEmpty) {
      setState(() {
        image = XFile(picked.path);
      });
      final name = uuid.v4();
      log(oldLink);
      if (oldLink.length > 6) {
        log('deleting old picture...');
        await FirebaseStorage.instance.refFromURL(oldLink).delete();
        log('done');
      }

      final db = FirebaseStorage.instance.ref("users/profile_images/${FirebaseAuth.instance.currentUser!.uid}/$name");

      await db.putFile(File(image!.path));
      final link = await db.getDownloadURL();
      await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update({'imguser_link': link});
      userImg_link = link;
      log('image has been set...');
      notifyListeners();
    }
  }

  String getImageName(XFile image) {
    return image.path.split("/").last;
  }

  void displayUser() {
    log(chalk.yellowBright.bold("========================================="));
    log(chalk.green.bold("Username: $username"));
    log(chalk.green.bold("first_name: $first_name"));
    log(chalk.green.bold("Last_name: $last_name"));
    log(chalk.green.bold("balance: $balance"));
    log(chalk.green.bold("phone number: $phone_number"));
    log(chalk.green.bold("registered: ${registered.toIso8601String()}"));
    log(chalk.green.bold("Gender: $gender"));
    log(chalk.yellowBright.bold("========================================="));
  }

  Future<void> logOut(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
                height: 250,
                width: 400,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 102, 5, 50),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.signika(color: Colors.black, fontSize: 24),
                      ),
                    ),
                    Container(
                      color: Color.fromARGB(255, 48, 8, 27),
                      child: Text(
                        'Are you sure you wanna logout?',
                        style: GoogleFonts.signika(color: Colors.black, fontSize: 24),
                      ),
                    ),
                    Container(alignment: Alignment.bottomRight, color: const Color.fromARGB(255, 102, 5, 50), child: ElevatedButton(onPressed: () {}, child: const Text('Log out'))),
                  ],
                )),
          );
        });
  }
}
