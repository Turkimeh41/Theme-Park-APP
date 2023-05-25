// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';

import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Handler/manager_firebase_handler.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrViewHandler {
  late QRViewController qrController;
  late Stream<Barcode> barcode;
  late StreamSubscription<Barcode> stream;
  late void Function(void Function()) setState;
  bool isAttemptingPayment = false;
  double opacityError = 0;
  void initStream({required Manager manager, required Activites insActivites, required BuildContext context}) {
    stream = qrController.scannedDataStream.listen((barcode) async => scanData(barcode, context, insActivites: insActivites, insManager: manager));
  }

  void pauseStream() {
    stream.pause();
  }

  void resumeStream() {
    stream.resume();
  }

  void cancelStream() {
    stream.cancel();
  }

  Future<void> pause3pointHalfSecondsStream() async {
    stream.pause();
    await Future.delayed(const Duration(milliseconds: 2000));
    stream.resume();
  }

  Future<void> scanData(Barcode barcode, BuildContext context, {required Manager insManager, required Activites insActivites}) async {
    if (barcode.code!.substring(0, 5) == 'USER-') {
      pauseStream();
      final userID = barcode.code!.substring(5);

      try {
        setState(() {
          isAttemptingPayment = true;
        });
        await ManagerFirebaseHandler.attemptUserPayment(userID, insActivites.selectedActivity, insManager);
        Navigator.of(context).pop();
      } on BalanceException catch (_) {
        setState(() {
          isAttemptingPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(
          child: Text(
            'Invalid, User has insufficent balance, not permitted!',
            style: GoogleFonts.signika(color: const Color.fromARGB(255, 129, 30, 23), fontSize: 16),
          ),
        )));
      }
    } else if (barcode.code!.substring(0, 6) == 'ANONY-') {
      pauseStream();
      final anonyID = barcode.code!.substring(6);
      setState(() {
        isAttemptingPayment = true;
      });
      try {
        await ManagerFirebaseHandler.attemptAnonyPayment(anonyID, insActivites.selectedActivity, insManager);
        Navigator.of(context).pop();
      } on BalanceException catch (_) {
        setState(() {
          isAttemptingPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(
          child: Text(
            'Invalid, the Provider of that anonymous user has insufficent Balance, not permitted!',
            style: GoogleFonts.signika(color: const Color.fromARGB(255, 129, 30, 23), fontSize: 16),
          ),
        )));
      }
    } else {
      //HANDLE ERRORS
    }
  }
}
