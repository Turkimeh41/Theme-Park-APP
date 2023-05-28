import 'dart:async';

import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:final_project/USERS/ENGAGING/engage_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> with SingleTickerProviderStateMixin {
  late AnimationController lottieController;
  ValueNotifier<int> notifier = ValueNotifier(4);
  @override
  void initState() {
    lottieController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    lottieController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ActivityEngagement>(context, listen: false).initializeUsersStream();

      Timer.periodic(const Duration(seconds: 1), (_) {
        notifier.value = notifier.value - 1;
      });
      Future.delayed(const Duration(milliseconds: 4500), () {
        Get.to(() => const EngagingScreen(), transition: Transition.zoom);
      });
    });
    lottieController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    lottieController.dispose();
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/done.json', width: 168, height: 168, controller: lottieController),
                ValueListenableBuilder(
                    valueListenable: notifier,
                    builder: (context, value, child) {
                      return RichText(text: TextSpan(style: GoogleFonts.signika(color: Colors.white, fontSize: 18), text: 'Navigating to Engagement Screen in ', children: [TextSpan(text: "$value")]));
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
