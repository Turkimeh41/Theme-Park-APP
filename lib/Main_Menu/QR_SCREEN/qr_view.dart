// ignore_for_file: non_constant_identifier_names

import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Handler/firebase_handler.dart';
import 'package:final_project/Provider/activites_provider.dart';
import 'package:final_project/Provider/participations_provider.dart';
import 'package:final_project/Provider/transactions_provider.dart';
import 'package:final_project/Provider/user_provider.dart' as u;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'package:lottie/lottie.dart';

class QRViewScreen extends StatefulWidget {
  const QRViewScreen({super.key});

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> with SingleTickerProviderStateMixin {
  Barcode? result;
  QRViewController? qrcontroller;
  bool status = false;
  final GlobalKey qrKey = GlobalKey();
  late AnimationController scanController;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void initState() {
    scanController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    super.initState();
  }

  @override
  dispose() {
    scanController.dispose();
    qrcontroller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insActivites = Provider.of<Activites>(context, listen: false);
    final user = Provider.of<u.User>(context, listen: false);
    final transaction = Provider.of<Transactions>(context, listen: false);
    final participation = Provider.of<Participations>(context, listen: false);
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 250.0 : 400.0;
    return Scaffold(
        body: SizedBox(
      width: dw,
      height: dh,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: (p0) {
              setState(() {
                log('qr assigned');
                qrcontroller = p0;
              });
              qrcontroller!.scannedDataStream.listen((scanData) async {
                result = scanData;

                if (result!.code!.substring(0, 5) == 'ACTV-') {
                  final String prefix_ID = result!.code!;
                  final actID = prefix_ID.substring(5);
                  final activity = insActivites.getActivityByID(actID);

                  try {
                    await user.attemptPayment(activity);
                    //payment should have deduced
                    await user.switchEngagement(activity.duration);

                    //we will attempt a payment first, if user has insufficent balance, a balanceException error will be thrown, where we won't add a transaction if that happened
                    transaction.addTransaction(activity);
                    participation.addParticipation(activity);
                    //increment one played activity to activites database
                    FirebaseHandler.incrementOnePlayedActivity(actID);
                  } on BalanceException catch (e) {
                    log(e.code);
                    log(e.details);
                  }
                } else {
                  //HANDLE ERROR IF QR CODE IS FROM OUR APP
                }
              });
            },
            overlay: QrScannerOverlayShape(borderColor: const Color.fromARGB(255, 97, 9, 31), cutOutSize: scanArea, borderRadius: 1.5, borderWidth: 7),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
          Positioned(
              bottom: dh * 0.15,
              child: IconButton(
                onPressed: () async {
                  log('flash toggled');
                  await qrcontroller?.toggleFlash();
                  setState(() {
                    status = !status;
                  });
                },
                icon: Icon(
                  Icons.flashlight_on_sharp,
                  color: status ? Colors.amber : Colors.grey,
                  size: status ? 48 : 36,
                ),
              )),
          Positioned(child: Lottie.asset('assets/animations/scan_red.json', controller: scanController)),
          Positioned(
              top: 50,
              left: 0,
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ))),
        ],
      ),
    ));
  }

  void _onPermissionSet(BuildContext context, QRViewController controller, bool permission) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $permission');
    if (!permission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
