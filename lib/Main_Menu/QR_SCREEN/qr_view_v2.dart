import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrViewV2 extends StatefulWidget {
  const QrViewV2({super.key});

  @override
  State<QrViewV2> createState() => _QrViewV2State();
}

class _QrViewV2State extends State<QrViewV2> {
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: dh,
        width: dw,
        child: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
                scanWindow: Rect.fromCenter(center: const Offset(0, 0), width: 300, height: 300),
                controller: MobileScannerController(returnImage: false),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    log('${barcode.rawValue}');
                  }
                }),
            ClipPath(
                clipper: CustomClipPath(),
                child: Container(
                  height: 300,
                  width: 300,
                  color: Colors.black.withOpacity(0.6),
                ))
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    path.addRect(rect);

    Rect holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 300,
      height: 300,
    );
    path.addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(10)));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
