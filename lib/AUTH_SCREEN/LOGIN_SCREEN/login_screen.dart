import 'dart:developer';
import 'package:final_project/AUTH_SCREEN/LOGIN_SCREEN/forget_password.dart';
import 'package:final_project/AUTH_SCREEN/LOGIN_SCREEN/login_textfields.dart';
import 'package:final_project/AUTH_SCREEN/Register_Screen/register_screen.dart';
import 'package:final_project/AUTH_SCREEN/auth_provider.dart';
import 'package:final_project/Handler/general_handler.dart';
import 'package:final_project/USERS/Provider/utility_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool loading = false;
  bool rememberMe = false;
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

  Future<void> storeRememberMe() async {
    log('beginning storing: $rememberMe on the device!');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember-me', rememberMe);
    log('Stored as $rememberMe');
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    final utility = Provider.of<Utility>(context);
    return ChangeNotifierProvider(
      create: (context) => LogUser(),
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
          child: Consumer<LogUser>(
            builder: (context, logUser, child) => Stack(
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
                    bottom: dh * 0.385,
                    left: dw * 0.07,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 0.36 * dh,
                        width: 0.85 * dw,
                      ),
                    )),
                Positioned(
                    bottom: dh * 0.41,
                    left: dw * 0.11,
                    child: SlideTransition(
                        position: slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Don't change this to constant! because i want to rebuilt all the widget with all the children, if it's constant, i can't rebuilt it!
                            // ignore: prefer_const_constructors
                            LoginTextFields(),
                            Row(
                              children: [
                                Transform.scale(
                                  scaleX: 1.1,
                                  scaleY: 1.1,
                                  child: Checkbox(
                                    activeColor: const Color.fromARGB(255, 110, 30, 63),
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  'Remember me?',
                                  style: GoogleFonts.acme(fontSize: 15.5),
                                )
                              ],
                            )
                          ],
                        ))),
                Positioned(
                  top: dh * 0.06,
                  width: 450,
                  child: FadeTransition(opacity: fadeAnimation, child: Image.asset('assets/images/streamers.png')),
                ),
                StatefulBuilder(builder: (context, builderState) {
                  return Positioned(
                      bottom: loading ? dh * 0.24 : dh * 0.36,
                      left: loading ? dw * 0.27 : dw * 0.141,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: !loading
                            ? NiceButtons(
                                borderColor: Colors.amber[900]!,
                                startColor: Colors.amber,
                                endColor: Colors.amber[800]!,
                                stretch: false,
                                width: dw * 0.7,
                                height: dh * 0.05,
                                onTap: (_) async {
                                  if (logUser.validateForm()) {
                                    log('Signing in...');
                                    builderState(() {
                                      loading = true;
                                    });
                                    try {
                                      final map = await GeneralHandler.login(logUser.username!, logUser.password!);
                                      log('Success!');
                                      await storeRememberMe();
                                      builderState(() {
                                        loading = false;
                                      });
                                      utility.currentUserType = map['type'];
                                      await GeneralHandler.loginToken(map['customToken']);
                                    } on FirebaseFunctionsException catch (error) {
                                      setState(() {
                                        loading = false;
                                        logUser.showErrors(error.message!, context);
                                        log(error.code);
                                        log(error.message!);
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.acme(color: Colors.white, fontSize: 27),
                                ),
                              )
                            : Lottie.asset('assets/animations/linear_loading_amber.json', width: 170, height: 170),
                      ));
                }),
                Positioned(
                  bottom: dh * 0.2,
                  left: dw * 0.24,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: InkWell(
                      onTap: () => Get.to(() => const ForgetPassword(), transition: Transition.zoom),
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
                      onTap: () {
                        Get.off(() => const RegisterScreen(), transition: Transition.upToDown);
                      },
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
        ),
      ),
    );
  }
}
