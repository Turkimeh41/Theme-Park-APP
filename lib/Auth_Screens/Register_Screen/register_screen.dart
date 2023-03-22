import 'dart:developer';

import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:final_project/Auth_Screens/Register_Screen/register_textfields.dart';
import 'package:final_project/Provider/useraddProviders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_project/Customs/GradientButton.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  late AnimationController slideController;
  late AnimationController fadeController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));
    slideAnimation = Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0)).animate(CurvedAnimation(parent: slideController, curve: Curves.linear));
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: fadeController, curve: Curves.linear));

    slideController.forward();
    fadeController.forward();
    super.initState();
  }

  @override
  void dispose() {
    slideController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
        create: (context) => RegUserAdd(),
        builder: (context, child) => Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            body: Container(
              height: dh,
              width: dw,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      left: dw * 0.135,
                      child: Container(
                        width: dh * 0.35,
                        height: dh * 0.35,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 240, 228, 218)),
                      )),
                  Positioned(
                      left: dw * 0.05,
                      top: dw * -0.02,
                      width: 350,
                      child: Image.asset(
                        'assets/images/add.png',
                      )),
                  //the White Container
                  Positioned(
                      bottom: dh * 0.09,
                      left: dw * 0.035,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: 0.621 * dh,
                          width: 0.92 * dw,
                        ),
                      )),
                  //register TextFields
                  RegisterTextFields(
                    slideAnimation: slideAnimation,
                  ),

                  Positioned(
                    bottom: dh * 0.03,
                    left: dw * 0.04,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: InkWell(
                        onTap: () {
                          Get.off(() => const LoginScreen(), transition: Transition.downToUp);
                        },
                        child: Text(
                          'already have an account?, Click here to Login now!',
                          style: GoogleFonts.acme(fontSize: 18, color: Colors.white, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
