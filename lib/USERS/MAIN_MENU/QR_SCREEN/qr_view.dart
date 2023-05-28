// ignore_for_file: non_constant_identifier_names

import 'dart:math' as math;

import 'package:final_project/Custom/color_filter_modes.dart';
import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:final_project/USERS/MAIN_MENU/QR_SCREEN/qr_view_handler.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:final_project/USERS/Provider/transactions_provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart' as u;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  QrViewHandler qrViewHandler = QrViewHandler();
  ColorFilterModes modes = ColorFilterModes();
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
      qrViewHandler.setState = setState;
    });
    flashController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  dispose() {
    scanController.dispose();
    qrViewHandler.cancelStream();
    qrViewHandler.qrController.dispose();
    flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insActivites = Provider.of<Activites>(context, listen: false);
    final user = Provider.of<u.User>(context, listen: false);
    final insTransactions = Provider.of<Transactions>(context, listen: false);
    final insParticipations = Provider.of<Participations>(context, listen: false);
    final insEngagement = Provider.of<ActivityEngagement>(context, listen: false);
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SizedBox(
      width: dw,
      height: dh,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BACK BUTTON RETURN

          Visibility(
            visible: qrViewHandler.attemptingPayment,
            child: Positioned(
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
          ),

          // QR VIEW

          QRView(
            key: qrKey,
            onQRViewCreated: (controller) {
              qrViewHandler.qrController = controller;
              qrViewHandler.initStream(context: context, insActivites: insActivites, insParticipations: insParticipations, insTransactions: insTransactions, user: user, insEngagement: insEngagement);
            },
            overlay: QrScannerOverlayShape(borderColor: const Color.fromARGB(255, 97, 9, 31), cutOutSize: 250, borderRadius: 1.5, borderWidth: 7),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),

          //Scan Animation

          Positioned(child: Lottie.asset('assets/animations/scan_red.json', controller: scanController)),

          //TOGGLE FLASH
          Positioned(
              bottom: 50,
              child: Transform.rotate(
                angle: 270 * math.pi / 180,
                child: ImageFiltered(
                  imageFilter: status ? modes.normal : modes.greyscale,
                  child: GestureDetector(
                      onTap: () async {
                        await qrViewHandler.qrController.toggleFlash();
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
          // TEXT ERROR WRONG QR CODE
          Positioned(
              bottom: 20,
              child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 2000),
                  opacity: qrViewHandler.opacityError,
                  child: Text(
                    'Error, Invalid QR CODE,\n make sure you scanned an activity!',
                    style: GoogleFonts.signika(color: const Color.fromARGB(255, 165, 27, 17)),
                  ))),

          Visibility(
            visible: qrViewHandler.attemptingPayment,
            child: Positioned.fill(
                child: Container(
              color: Colors.black.withOpacity(0.5),
            )),
          ),
          Visibility(
            visible: qrViewHandler.attemptingPayment,
            child: const Positioned(
                child: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 97, 9, 31),
              ),
            )),
          ),
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
