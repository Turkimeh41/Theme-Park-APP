// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:math' as math;

import 'package:final_project/Custom/color_filter_modes.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/QR_VIEW/qr_viewhandler.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
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

class _QRViewScreenState extends State<QRViewScreen> with TickerProviderStateMixin {
  bool status = false;
  final GlobalKey qrKey = GlobalKey();
  late AnimationController scanController;
  late AnimationController flashController;
  QrViewHandler qrhandler = QrViewHandler();
  ColorFilterModes mode = ColorFilterModes();
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void initState() {
    scanController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    flashController = AnimationController(vsync: this, duration: const Duration(seconds: 2), value: 0.1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      qrhandler.setState = setState;
    });
    flashController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  dispose() {
    scanController.dispose();
    flashController.dispose();
    qrhandler.qrController.dispose();
    qrhandler.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insActivites = Provider.of<Activites>(context, listen: false);
    final insManager = Provider.of<Manager>(context, listen: false);
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    var scanArea = 250.0;
    return Scaffold(
        body: SizedBox(
      width: dw,
      height: dh,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: (controller) {
              qrhandler.qrController = controller;
              qrhandler.initStream(manager: insManager, insActivites: insActivites, context: context);
            },
            overlay: QrScannerOverlayShape(borderColor: const Color.fromARGB(255, 97, 9, 31), cutOutSize: scanArea, borderRadius: 1.5, borderWidth: 7),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
          Positioned(
              bottom: 50,
              child: Transform.rotate(
                angle: 270 * math.pi / 180,
                child: ImageFiltered(
                  imageFilter: status ? mode.normal : mode.greyscale,
                  child: GestureDetector(
                      onTap: () async {
                        await qrhandler.qrController.toggleFlash();
                        if (status) {
                          log('reversing');
                          flashController.animateBack(0.1, duration: const Duration(milliseconds: 50));
                        } else {
                          log('forwarding');
                          flashController.animateTo(0.5, duration: const Duration(seconds: 2));
                        }
                        status = !status;
                      },
                      child: Lottie.asset('assets/animations/flash.json', controller: flashController)),
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
          Positioned.fill(
              child: Visibility(
            visible: qrhandler.isAttemptingPayment,
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          )),
          Visibility(
            visible: qrhandler.isAttemptingPayment,
            child: const Positioned(
                child: Center(
              child: CircularProgressIndicator(),
            )),
          )
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
