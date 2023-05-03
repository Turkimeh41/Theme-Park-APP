// ignore_for_file: non_constant_identifier_names
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
}
