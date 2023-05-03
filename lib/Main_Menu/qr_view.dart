// ignore_for_file: non_constant_identifier_names

import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Handler/cloud_handler.dart';
import 'package:final_project/Main_Menu/mainmenu_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Widget build(BuildContext context) {
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
                  try {
                    await CloudHandler.attemptPayment(prefix_ID);
                    Get.off(() => const MainMenuScreen());
                  } on BalanceException catch (e) {
                    log(e.code);
                    log(e.details);
                  }
                } else {
                  //HANDLE ERROR
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

  @override
  void dispose() {
    qrcontroller?.dispose();
    super.dispose();
  }
}
