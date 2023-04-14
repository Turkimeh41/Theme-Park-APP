// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Handler/cloud_handler.dart';
import 'package:final_project/Handler/network_function.dart';
import 'package:final_project/Main_Menu/qr_example.dart';
import 'package:final_project/Provider/participations_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:provider/provider.dart';
import '../Provider/transactions_provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

bool _loading = false;

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder(builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
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
                child: const Text('Add Activity'),
                onPressed: () async {
                  if (await Network.validateNetwork()) {
                    log('Checking network...');
                    log('Network Aaviliable !');
                    final function = FirebaseFunctions.instanceFor(region: "europe-west1");
                    log('adding activity....');
                    await function.httpsCallable('addActivity').call(
                        {'name': 'Basilik Roller Coaster', 'description': 'fearful ride, that takes you to experience you never tried!', 'type': 'Thrill Rides', 'duration': 15.00, 'price': 29.99});
                    log('Activity added!');
                  }
                },
              ),
              ElevatedButton(
                  child: const Text('Attempt a payment'),
                  onPressed: () async {
                    log('attempting...');
                    try {
                      final actID = await CloudHandler.attemptPayment('ACTV-7237a5863a93eefeb090e240b645b9434dffcb6f');
                      Provider.of<Transactions>(context, listen: false).addTransaction(actID);
                      log('creating a new transaction...');
                      //creates a transaction for user.

                      log('created!');
                      //adds a participations for the game the user joined.
                      log('adding that user participated...');
                      Provider.of<Participations>(context, listen: false).newParticipation(actID);
                      log('done!');
                    } on BalanceException catch (e) {
                      log(e.code);
                      log(e.details);
                    }
                    log('done!');
                  }),
              ElevatedButton(
                  child: const Text('Camera QR'),
                  onPressed: () async {
                    Get.to(const QRViewExample());
                  }),
            ],
          ),
        );
      }),
    );
  }
}
