import 'package:final_project/Auth_Screens/Login_Screen/login_textfields.dart';
import 'package:final_project/Customs/GradientButton.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
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
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
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
              left: dw * 0.16,
              bottom: dh * 0.92,
              child: Text(
                'We\'re happy to see you back!',
                style: GoogleFonts.acme(color: Colors.white, fontSize: 24),
              ),
            ),
            Positioned(
              left: dw * 0.31,
              bottom: dh * 0.75,
              child: Row(
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.acme(color: Colors.white, fontSize: 56),
                  ),
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.amber,
                    size: 32,
                  )
                ],
              ),
            ),
            Positioned(
                bottom: dh * 0.34,
                left: dw * 0.07,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    height: 0.4 * dh,
                    width: 0.85 * dw,
                  ),
                )),
            Positioned(bottom: dh * 0.39, left: dw * 0.11, child: SlideTransition(position: slideAnimation, child: LoginTextFields())),
            Positioned(
              top: dh * 0.06,
              width: 450,
              child: FadeTransition(opacity: fadeAnimation, child: Image.asset('assets/images/streamers.png')),
            ),
            //Ballon
            /*  Positioned(
                bottom: dh * 0.75,
                left: dw * -0.04,
                child: Image.asset(
                  'assets/images/ballon1.png',
                  width: 132,
                  height: 132,
                )), */
            Positioned(
                bottom: dh * 0.31,
                left: dw * 0.135,
                child: SlideTransition(
                  position: slideAnimation,
                  child: GradientButton(
                    style: GoogleFonts.acme(color: Colors.white, fontSize: 27),
                    width: dw * 0.7,
                    height: dh * 0.06,
                    'Login',
                    onTap: () {},
                    radius: 20,
                    gradient: LinearGradient(colors: [Colors.amber, Colors.amber[800]!]),
                  ),
                )),
            Positioned(
              bottom: dh * 0.2,
              left: dw * 0.24,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    'Forgot password?, Click here',
                    style: GoogleFonts.acme(fontSize: 18, color: Colors.white, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: dh * 0.06,
              left: dw * 0.1,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    'Not Registered?, Click here to Register now!',
                    style: GoogleFonts.acme(fontSize: 18, color: Colors.white, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
