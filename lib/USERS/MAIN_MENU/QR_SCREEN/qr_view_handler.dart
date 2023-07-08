// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Handler/user_firebase_handler.dart';
import 'package:final_project/USERS/DIALOG/user_dialog.dart';
import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:final_project/USERS/Provider/transactions_provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrViewHandler {
  late QRViewController qrController;
  late Stream<Barcode> barcode;
  late StreamSubscription<Barcode> stream;
  late void Function(void Function()) setState;
  bool attemptingPayment = false;
  double opacityError = 0;
  void initStream(
      {required User user,
      required Activites insActivites,
      required Participations insParticipations,
      required Transactions insTransactions,
      required ActivityEngagement insEngagement,
      required BuildContext context}) {
    stream = qrController.scannedDataStream.listen((barcode) async {
      if (barcode.code!.substring(0, 5) == 'ACTV-') {
        pauseStream();

        final String prefix_ID = barcode.code!;
        final activityID = prefix_ID.substring(5);

        final activity = insActivites.getActivityByID(activityID);

        setState(() {
          attemptingPayment = true;
        });
        try {
          await UserFirebaseHandler.attemptPayment(activity, user, insParticipations, insTransactions, insEngagement);
          setState(() {
            attemptingPayment = false;
          });
          Navigator.of(context).pop();
        } on BalanceException catch (balanceException) {
          setState(() {
            attemptingPayment = false;
          });
          log(balanceException.code);
          log(balanceException.details);
          UserDialog.balanceDialog(context);

//my idea is it show dialog, where it asks for the user if he wants to recharge, and transfer him to the recharge page
        }

        //payment should have deduced
      } else {
        setState(() {
          opacityError = 1.0;
        });
        await pause3pointHalfSecondsStream();
        setState(() {
          opacityError = 0.0;
        });
      }
    });
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
}
