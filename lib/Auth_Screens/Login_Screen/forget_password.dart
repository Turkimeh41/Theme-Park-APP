import 'dart:async';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});
  static const routeName = '/forgetPass';
  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> with SingleTickerProviderStateMixin {
  late TextEditingController emailController;
  late FocusNode emailFocus;
  late KeyboardVisibilityController softkeyboardController;
  late StreamSubscription<bool> keyboardSubscription;

  bool visibility = false;
  late AnimationController controller;
  late Animation<double> opacityAnimation;
  String success = '';
  Color? color;
  String? emailError;
  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    opacityAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    emailController = TextEditingController();
    emailFocus = FocusNode();
    softkeyboardController = KeyboardVisibilityController();
    emailFocus.addListener(() {});

    keyboardSubscription = softkeyboardController.onChange.listen((visible) {
      if (context.mounted) {
        if (visible) {
          setState(() {
            visibility = visible;
          });
        } else {
          setState(() {
            visibility = visible;
          });
        }
      }
    });
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    controller.dispose();
    emailFocus.removeListener(() {});
    keyboardSubscription.cancel();
    super.dispose();
  }

  bool validateEmail() {
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Please fill in the Email Address field.';
      });
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text)) {
      setState(() {
        emailError = 'INVALID, Recheck your email input.';
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24)),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      body: SizedBox(
        width: dw,
        height: dh,
        child: GestureDetector(
          onTap: () {
            setState(() {
              emailFocus.unfocus();
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                ),
              ),
              Positioned(
                  top: 100,
                  left: 20,
                  child: Text(
                    'Forgot Password',
                    style: GoogleFonts.signika(color: Colors.white, fontSize: 28),
                  )),
              Positioned(
                  top: 140,
                  left: 35,
                  child: Text('Please specifiy your Email \n    to sent a Reset password prompt to you!', style: GoogleFonts.signika(color: const Color.fromARGB(255, 240, 204, 204), fontSize: 16))),
              AnimatedPositioned(
                bottom: visibility ? 450 : 350,
                duration: const Duration(milliseconds: 350),
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                      controller: emailController,
                      onChanged: (value) {
                        if (emailError != null) {
                          setState(() {
                            emailError = null;
                          });
                        }
                      },
                      focusNode: emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.signika(fontSize: 18),
                      decoration: InputDecoration(
                        errorText: emailError,
                        prefixIcon: Icon(
                          Icons.email,
                          size: 28,
                          color: emailFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 221, 191, 191),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        errorStyle: GoogleFonts.signika(fontSize: 12.5),
                        labelText: 'Email Address',
                        labelStyle:
                            GoogleFonts.acme(fontSize: emailFocus.hasFocus ? 24 : 16, color: emailFocus.hasFocus ? const Color.fromARGB(255, 228, 149, 182) : const Color.fromARGB(255, 102, 100, 100)),
                      )),
                ),
              ),
              AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  bottom: visibility ? 300 : 200,
                  child: NiceButtons(
                    progress: true,
                    borderColor: Colors.amber[800]!,
                    startColor: Colors.amber,
                    endColor: Colors.amber[800]!,
                    gradientOrientation: GradientOrientation.Horizontal,
                    stretch: false,
                    width: dw * 0.56,
                    height: dh * 0.06,
                    onTap: (finish) async {
                      bool validate = validateEmail();
                      log('email validated with: $validate');
                      if (validate) {
                        try {
                          await FirebaseFunctions.instanceFor(region: "europe-west1").httpsCallable('sendEmailForgetHTML').call({"email_address": emailController.text});
                          setState(() {
                            controller.forward();
                            finish();
                          });
                        } on FirebaseFunctionsException catch (e) {
                          log(e.code);
                          log(e.message!);
                          setState(() {
                            emailError = e.message!;
                            finish();
                          });
                        }
                      }
                      finish();
                    },
                    child: Text(
                      'Confirm',
                      style: GoogleFonts.acme(color: Colors.white, fontSize: 27),
                    ),
                  )),
              Positioned(
                  bottom: 100,
                  child: FadeTransition(
                    opacity: opacityAnimation,
                    child: Text(
                      'We have sent an email to the address associated with your account,\n please check your inbox to reset your password ',
                      style: GoogleFonts.signika(color: const Color.fromARGB(255, 70, 204, 74), fontSize: 12),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
