// ignore_for_file: non_constant_identifier_names

import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Handler/cloud_handler.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'package:lottie/lottie.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? qrcontroller;
  bool status = false;
  final GlobalKey qrKey = GlobalKey();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
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
              qrcontroller!.scannedDataStream.listen((scanData) {
                result = scanData;

                if (result!.code!.substring(0, 4) == 'ACTV-') {
                  final String prefix_ID = result!.code!;
                  try {
                    CloudHandler.attemptPayment(prefix_ID);
                  } on BalanceException catch (e) {
                    log(e.code);
                    log(e.details);
                  }
                } else {
                  //HANDLE ERROR
                }
              });
            },
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              cutOutSize: scanArea,
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
          Positioned(
              bottom: dh * 0.15,
              child: IconButton(
                onPressed: () async {
                  log('test');
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
          Positioned(child: Lottie.asset('assets/animations/Comp.json', width: 600)),
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
