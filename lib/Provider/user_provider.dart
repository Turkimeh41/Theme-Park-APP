// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chalkdart/chalk.dart';
import 'package:chalkdart/chalk_x11.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Model/anonymous_user.dart';
import 'package:final_project/Model/balance_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class User with ChangeNotifier {
  late String username;
  late int points;
  late String first_name;
  late String last_name;
  late double balance;
  late String emailAddress;
  late String phone_number;
  late DateTime registered;
  late int gender;
  late String qrURL;
  late String? imgURL;
  List<AmountEntry> _entries = [];
  List<AnonymousUser> _anonyUsers = [];
  bool loading = false;
//bool loading handler for the bottomsheet, it will be accessed through this user instance

  Future<void> setUser() async {
    log(chalk.lightGoldenrodYellow.bold('fetching and setting user data...'));
    final futures = await Future.wait([
      FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
      FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection("AmountEntry").orderBy("date", descending: true).get(),
      FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Anonymous_Users").orderBy('label').get()
    ]);
    final documentReference = futures[0] as DocumentSnapshot<Map<String, dynamic>>;
    final balanceEntries = (futures[1] as QuerySnapshot<Map<String, dynamic>>);
    final anonymousUsers = (futures[2] as QuerySnapshot<Map<String, dynamic>>);
    if (balanceEntries.size != 0) {
      final enteries = balanceEntries.docs;
      final List<AmountEntry> loadedEnteries = [];
      for (int i = 0; i < enteries.length; i++) {
        final data = enteries[i].data();
        loadedEnteries.add(AmountEntry(id: enteries[i].id, amount: data['amount'], date: (data['date'] as Timestamp).toDate()));
      }
      _entries = loadedEnteries;
    }
    if (anonymousUsers.size != 0) {
      final anonymousDocs = anonymousUsers.docs;
      final List<AnonymousUser> loadedAnonyUsers = [];
      for (int i = 0; i < anonymousDocs.length; i++) {
        final id = anonymousDocs[i].id;
        final data = anonymousDocs[i].data();
        loadedAnonyUsers.add(AnonymousUser(id: id, assignedDate: (data['assignedDate'] as Timestamp).toDate(), qrURL: data['qrURL'], label: data['label']));
      }
      _anonyUsers = loadedAnonyUsers;
    }
    final userData = documentReference.data();
    username = userData!['username'];
    emailAddress = userData['email'];
    first_name = userData['first_name'];
    last_name = userData['last_name'];
    if (userData['balance'] is int) {
      balance = (userData['balance'] as int).toDouble();
    } else {
      balance = userData['balance'];
    }
    points = userData["points"];

    qrURL = userData['qrURL'];

    imgURL = userData['imgURL'];
    phone_number = userData['phone'];
    registered = (userData['registered'] as Timestamp).toDate();
    gender = userData['gender'];
    log(chalk.lightGoldenrodYellow.bold('User has been set'));
    notifyListeners();
  }

  List<AnonymousUser> get getAnonymousUsers {
    return [..._anonyUsers];
  }

  List<AmountEntry> get getEntries {
    return [..._entries];
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

  Future<void> rechargeBalance(double amount) async {
    await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).update({"balance": balance + amount});
    balance = balance + amount;
    await newAmountEntry(amount);
    notifyListeners();
  }

  Future<void> newAmountEntry(double amount) async {
    final timestamp = Timestamp.now();
    final response = await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection('AmountEntry').add({"amount": amount, "date": timestamp});
    //run time add
    _entries.insert(0, AmountEntry(id: response.id, amount: amount, date: timestamp.toDate()));
  }

  Future<void> updateUser({required String first_name, required String last_name, required String emailAddress}) async {
    await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update({"first_name": first_name, "last_name": last_name, "email_address": emailAddress});
    this.first_name = first_name;
    this.last_name = last_name;
    this.emailAddress = emailAddress;
    notifyListeners();
  }

  Future<void> editPicture(Function(void Function()) setStateful, ImageSource source) async {
    final pick = ImagePicker();
    const uuid = Uuid();
    XFile? image;
    final picked = await pick.pickImage(source: source, maxHeight: 256, maxWidth: 256);
    if (picked != null && picked.path.isNotEmpty) {
      setStateful(() {
        image = XFile(picked.path);
        loading = true;
      });
      final name = uuid.v4();
      if (imgURL != null) {
        log('deleting old picture...');
        await FirebaseStorage.instance.refFromURL(imgURL!).delete();
        log('done');
      }

      final db = FirebaseStorage.instance.ref("users/profile_images/${FirebaseAuth.instance.currentUser!.uid}/$name");

      await db.putFile(File(image!.path));
      final imgLink = await db.getDownloadURL();
      await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update({'imgURL': imgLink});
      imgURL = imgLink;
      log('image has been set...');
      setStateful(() {
        loading = false;
      });
      notifyListeners();
    }
  }

  String getImageName(XFile image) {
    return image.path.split("/").last;
  }

  Future<void> showSheetImage(BuildContext context) async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateful) {
            late Timer timer;
            ValueNotifier<String> dotNotifier = ValueNotifier('.');
            if (loading) {
              timer = Timer.periodic(const Duration(seconds: 1), (_) {
                if (dotNotifier.value != '...') {
                  dotNotifier.value = '${dotNotifier.value}.';
                } else {
                  dotNotifier.value = '.';
                }
              });
            }
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                color: Color.fromARGB(255, 223, 205, 205),
              ),
              height: 150,
              child: loading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0, top: 30, bottom: 10),
                          child: ValueListenableBuilder(
                            valueListenable: dotNotifier,
                            builder: (context, dot, child) {
                              return RichText(
                                text: TextSpan(
                                    text: 'uploading the Image',
                                    style: GoogleFonts.signika(color: const Color.fromARGB(255, 143, 102, 102), fontWeight: FontWeight.bold, fontSize: 20),
                                    children: [TextSpan(text: dot)]),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    fixedSize: const MaterialStatePropertyAll(Size(150, 40)),
                                    backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 102, 5, 50))),
                                onPressed: () async {
                                  await editPicture(setStateful, ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Camera', style: GoogleFonts.signika(fontSize: 18))),
                            ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    fixedSize: const MaterialStatePropertyAll(Size(150, 40)),
                                    backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 102, 5, 50))),
                                onPressed: () async {
                                  await editPicture(setStateful, ImageSource.gallery);
                                  timer.cancel();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Gallery', style: GoogleFonts.signika(fontSize: 18)))
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0, top: 30, bottom: 10),
                          child: Text(
                            'Choose an option ',
                            style: GoogleFonts.signika(color: const Color.fromARGB(255, 143, 102, 102), fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    fixedSize: const MaterialStatePropertyAll(Size(150, 40)),
                                    backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 102, 5, 50))),
                                onPressed: () async {
                                  await editPicture(setStateful, ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Camera', style: GoogleFonts.signika(fontSize: 18))),
                            ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    fixedSize: const MaterialStatePropertyAll(Size(150, 40)),
                                    backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 102, 5, 50))),
                                onPressed: () async {
                                  await editPicture(setStateful, ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Gallery', style: GoogleFonts.signika(fontSize: 18)))
                          ],
                        ),
                      ],
                    ),
            );
          });
        });
  }

  Future<void> confirmEditDialog(BuildContext context, String first_name, String last_name, String email_address) async {
    await showDialog(
        context: context,
        builder: (context) {
          bool loading = false;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: StatefulBuilder(builder: (context, setStateful) {
              return Container(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(color: const Color.fromARGB(255, 102, 5, 50), borderRadius: BorderRadius.circular(15)),
                height: 270,
                width: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Confirm',
                            style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.cancel))
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Color.fromARGB(255, 230, 158, 191),
                      thickness: 1.2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 40),
                      child: Text(
                        'Are you sure you wanna Confirm with the changed details',
                        style: GoogleFonts.signika(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Color.fromARGB(255, 230, 158, 191),
                      thickness: 1.2,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.0, right: loading ? 40 : 20),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.amber)
                            : ElevatedButton(
                                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.amber), fixedSize: MaterialStatePropertyAll(Size(120, 35))),
                                onPressed: () async {
                                  setStateful(() {
                                    loading = true;
                                  });
                                  await updateUser(first_name: first_name, last_name: last_name, emailAddress: email_address);
                                  setStateful(() {
                                    loading = false;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Confirm',
                                  style: GoogleFonts.signika(color: Colors.white, fontSize: 22.2),
                                )),
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }
}
