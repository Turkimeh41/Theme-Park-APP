// ignore_for_file: unused_import

import 'dart:async';
import 'dart:developer';
import 'package:final_project/data_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.rocketNotifier, required this.textNotifier, super.key});
  final ValueNotifier<int> rocketNotifier;
  final ValueNotifier<String> textNotifier;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  ValueNotifier dotNotifier = ValueNotifier<String>('.');
  @override
  void initState() {
    rocketNotifier.addListener(() {
      if (rocketNotifier.value == 1) {
        controller.forward();
      }
    });

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(const Duration(milliseconds: 650), (timer) {
        if (dotNotifier.value == '.') {
          dotNotifier.value = '..';
        } else if (dotNotifier.value == '..') {
          dotNotifier.value = '...';
        } else {
          dotNotifier.value = '.';
        }
      });
    });

    controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    dotNotifier.removeListener(() {});
    controller.dispose();
    super.dispose();
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
            ValueListenableBuilder(
                valueListenable: rocketNotifier,
                builder: (context, choice, child) {
                  if (choice == 0) {
                    return Positioned(bottom: 0.45 * dh, child: Lottie.asset('assets/animations/rocket_loading.json', width: 384));
                  }
                  return Positioned(bottom: 0.45 * dh, child: Lottie.asset('assets/animations/rocket_done.json', width: 384, controller: controller));
                }),
            Positioned(
                bottom: dh * 0.3,
                child: ValueListenableBuilder(
                  valueListenable: textNotifier,
                  builder: (context, text, child) {
                    return ValueListenableBuilder(
                      builder: (context, dot, child) {
                        return rocketNotifier.value != 1
                            ? Container(
                                alignment: Alignment.center,
                                width: 300,
                                child: RichText(
                                  text: TextSpan(
                                    text: widget.textNotifier.value,
                                    children: [TextSpan(text: dot, style: GoogleFonts.acme(fontSize: 26))],
                                    style: GoogleFonts.acme(fontSize: 26, color: Colors.white),
                                  ),
                                ),
                              )
                            : Text(widget.textNotifier.value, style: GoogleFonts.acme(fontSize: 26, color: Colors.white));
                      },
                      valueListenable: dotNotifier,
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}
