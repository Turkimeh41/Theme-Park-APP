// ignore_for_file: unused_import

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ValueNotifier index = ValueNotifier<String>('.');
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(const Duration(milliseconds: 650), (timer) {
        if (index.value == '.') {
          index.value = '..';
        } else if (index.value == '..') {
          index.value = '...';
        } else {
          index.value = '.';
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: dh,
        width: dw,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)])),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Lottie.asset('assets/animations/Paperplane.json'),
            Positioned(
                bottom: dh * 0.35,
                child: ValueListenableBuilder(
                  valueListenable: index,
                  builder: (context, value, child) {
                    return RichText(
                      text: TextSpan(
                          children: [TextSpan(text: value, style: GoogleFonts.acme(fontSize: 26))],
                          text: 'Making everything ready for you',
                          style: GoogleFonts.acme(fontSize: 26, color: Colors.white)),
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}
