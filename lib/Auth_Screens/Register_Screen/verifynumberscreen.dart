import 'package:final_project/Handler/api_handler.dart';
import 'package:final_project/Page_View/pageview_screen.dart';
import 'package:final_project/Handler/cloud_handler.dart';
import 'package:final_project/Main_Menu/mainmenu_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Provider/userauth_provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class VerifyNumber extends StatefulWidget {
  const VerifyNumber(this.user, this.smsCode, {super.key});
  final RegUser user;
  final String smsCode;
  @override
  State<VerifyNumber> createState() => _VerifyNumberState();
}

final key = GlobalKey<FormState>();

class _VerifyNumberState extends State<VerifyNumber> with TickerProviderStateMixin {
  var maskFormatter = MaskTextInputFormatter(mask: '#');
  String? digit1;
  String? digit2;
  String? digit3;
  String? digit4;
  bool error1 = false;
  bool error2 = false;
  bool error3 = false;
  bool error4 = false;
  bool visible = false;
  bool loading = false;

  String smsInput = '';
  late StreamSubscription<bool> keyboardlistener;
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  late AnimationController sizeController;
  late Animation<Size> sizeAnimation;
  double textMargin = 0;
  double otpMargin = 0;
  double buttonMargin = 0;

  @override
  void initState() {
    // var dw = (window.physicalSize.shortestSide / window.devicePixelRatio);
    var dh = (window.physicalSize.longestSide / window.devicePixelRatio);
    fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    fadeAnimation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: fadeController, curve: Curves.linear));
    sizeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    sizeAnimation = Tween<Size>(begin: Size(double.infinity, dh), end: Size(double.infinity, dh * 0.4)).animate(CurvedAnimation(parent: sizeController, curve: Curves.linear));

    keyboardlistener = KeyboardVisibilityController().onChange.listen((visible) {
      if (visible) {
        log('Running forward animations');
        fadeController.forward();
        sizeController.forward();
      } else {
        log('Running reverse animations');
        fadeController.reverse();
        sizeController.reverse();
      }
    });
    //invokes whenever the object changes
    sizeController.addListener(() {
      if (sizeController.status == AnimationStatus.forward) {
        textMargin = textMargin + 0.8;
        otpMargin = otpMargin + 2.8;
        buttonMargin = buttonMargin + 4.2;
      } else if (sizeController.status == AnimationStatus.reverse) {
        textMargin = textMargin - 0.8;
        otpMargin = otpMargin - 2.8;
        buttonMargin = buttonMargin - 4.2;
      }
    });
    //invokes whenever the status changes
    sizeController.addStatusListener((status) {
      if (sizeController.status == AnimationStatus.dismissed) {
        textMargin = 0;
        otpMargin = 0;
        buttonMargin = 0;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    fadeController.dispose();
    sizeController.dispose();
    keyboardlistener.cancel();

    super.dispose();
  }

  bool validate() {
    bool isvalid = key.currentState!.validate();
    if (!isvalid) {
      log('user validation: wrong');
      return false;
    }
    log('user validation: correct');
    return true;
  }

  String formatphone(String phone) {
    final last4Digits = phone.substring(phone.length - 4);
    final asterisks = '*' * (phone.length - 4);
    return '$asterisks$last4Digits';
  }

  String? fieldValidator(int field, digit) {
    switch (field) {
      case 1:
        if (digit!.isEmpty) {
          error1 = true;
          return '';
        }
        break;
      case 2:
        if (digit!.isEmpty) {
          error2 = true;
          return '';
        }
        break;
      case 3:
        if (digit!.isEmpty) {
          error3 = true;
          return '';
        }
        break;
      case 4:
        if (digit!.isEmpty) {
          error4 = true;
          return '';
        }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: key,
        child: Container(
          width: dw,
          height: dh,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)])),
          child: Stack(
            children: [
              Positioned(
                top: dh * 0.05,
                left: dw * 0.03,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Transform.scale(
                          scaleX: -1,
                          child: const Icon(
                            Icons.arrow_right_alt_sharp,
                            color: Colors.white,
                            size: 48,
                          ),
                        )),
                  ],
                ),
              ), //Illustration
              AnimatedBuilder(
                animation: fadeController,
                builder: (context, child) {
                  return Positioned(
                      top: dh * 0.1,
                      left: dw * 0.18,
                      child: FadeTransition(
                        opacity: fadeAnimation,
                        child: Image.asset(
                          'assets/images/Enter_OTP.png',
                          width: dw * 0.6,
                        ),
                      ));
                },
              ),
              //Verifcation code text
              AnimatedBuilder(
                  animation: sizeController,
                  builder: (context, child) {
                    return Positioned(
                      top: sizeAnimation.value.height * 0.45,
                      left: dw * 0.04,
                      child: Text(
                        'Verifcation Code',
                        style: GoogleFonts.acme(color: Colors.white, fontSize: 32),
                      ),
                    );
                  }),
              //Verifcation code sent to phone text
              AnimatedBuilder(
                  animation: sizeController,
                  builder: (context, child) {
                    return Positioned(
                      top: sizeAnimation.value.height * 0.51 + textMargin,
                      left: dw * 0.07,
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(text: 'We\'ve Sent a verifcation code to number: ', style: GoogleFonts.roboto(fontSize: 18)),
                        const TextSpan(text: '\n'), //
                        TextSpan(text: '(+966) ${formatphone(widget.user.phonenumber!)}', style: GoogleFonts.acme(color: const Color.fromARGB(255, 245, 228, 172), fontSize: 24))
                      ])),
                    );
                  }),
              //OTP Digit fields
              AnimatedBuilder(
                animation: sizeController,
                builder: (context, child) {
                  return Positioned(
                      top: sizeAnimation.value.height * 0.63 + otpMargin,
                      width: dw,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatefulBuilder(builder: (context, setStateful) {
                            return Container(
                              width: dw * 0.16,
                              height: dh * 0.09,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: error1 ? Border.all(color: Colors.red, width: 2.5) : null),
                              child: TextFormField(
                                initialValue: digit1,
                                validator: (value) => fieldValidator(1, value),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                                inputFormatters: [maskFormatter],
                                style: GoogleFonts.acme(fontSize: 42),
                                onChanged: (value) {
                                  digit1 = value;
                                  if (error1) {
                                    setStateful(() {
                                      error1 = false;
                                    });
                                  }
                                  if (value.length == 1) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            );
                          }),
                          StatefulBuilder(
                            builder: (context, setStateful) {
                              return Container(
                                width: dw * 0.16,
                                height: dh * 0.09,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: error2 ? Border.all(color: Colors.red, width: 2.5) : null),
                                child: TextFormField(
                                  initialValue: digit2,
                                  validator: (value) => fieldValidator(2, value),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                                  ),
                                  inputFormatters: [maskFormatter],
                                  style: GoogleFonts.acme(fontSize: 42),
                                  onChanged: (value) {
                                    digit2 = value;
                                    if (error2) {
                                      setStateful(() {
                                        error2 = false;
                                      });
                                    }
                                    if (value.length == 1) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          StatefulBuilder(builder: (context, setStateful) {
                            return Container(
                              width: dw * 0.16,
                              height: dh * 0.09,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: error3 ? Border.all(color: Colors.red, width: 2.5) : null),
                              child: TextFormField(
                                validator: (value) => fieldValidator(3, value),
                                initialValue: digit3,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                                inputFormatters: [maskFormatter],
                                style: GoogleFonts.acme(fontSize: 42),
                                onChanged: (value) {
                                  digit3 = value;
                                  if (error3) {
                                    setStateful(() {
                                      error3 = false;
                                    });
                                  }
                                  if (value.length == 1) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            );
                          }),
                          StatefulBuilder(builder: (context, setStateful) {
                            return Container(
                              width: dw * 0.16,
                              height: dh * 0.09,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: error4 ? Border.all(color: Colors.red, width: 2.5) : null),
                              child: TextFormField(
                                initialValue: digit4,
                                validator: (value) => fieldValidator(4, value),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                                ),
                                inputFormatters: [maskFormatter],
                                style: GoogleFonts.acme(fontSize: 42),
                                onChanged: (value) {
                                  digit4 = value;
                                  if (error4) {
                                    setStateful(() {
                                      error4 = false;
                                    });
                                  }
                                  if (value.length == 1) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ));
                },
              ),
              //Submit Button
              AnimatedBuilder(
                  animation: sizeController,
                  builder: (context, child) {
                    return Positioned(
                      top: sizeAnimation.value.height * 0.85 + buttonMargin,
                      left: dw * 0.245,
                      child: StatefulBuilder(builder: (context, builderState) {
                        return !loading
                            ? NiceButtons(
                                borderColor: Colors.amber[900]!,
                                gradientOrientation: GradientOrientation.Horizontal,
                                startColor: Colors.amber,
                                endColor: Colors.amber[800]!,
                                stretch: false,
                                height: 50,
                                width: 200,
                                child: Text(
                                  'Submit',
                                  style: GoogleFonts.acme(color: Colors.white, fontSize: 28),
                                ),
                                onTap: (_) async {
                                  if (validate()) {
                                    builderState(() {
                                      loading = true;
                                    });
                                    smsInput = digit1! + digit2! + digit3! + digit4!;
                                    log(smsInput);
                                    log(widget.smsCode);
                                    if (smsInput == widget.smsCode) {
                                      log('adding User...');
                                      try {
                                        //add user function, will add user then logs
                                        Map<String, dynamic> returned = await CloudHandler.addUser(widget.user.username!, widget.user.password!, widget.user.firstName!, widget.user.lastName!,
                                            widget.user.emailAddress!, widget.user.phonenumber!, widget.user.gender!);
                                        log('Success!');
                                        builderState(() {
                                          loading = false;
                                        });
                                        await CloudHandler.login(returned['token']!);
                                        log('Signing in...');
                                        ApiHandler.setMetaData(returned['key']!, returned['iv']);
                                        final pref = await SharedPreferences.getInstance();
                                        // ignore: non_constant_identifier_names
                                        bool intro_done = pref.getBool('intro-done') ?? false;
                                        log('intro-done: $intro_done');
                                        if (intro_done) {
                                          Get.off(() => const MainMenuScreen());
                                        } else {
                                          Get.off(() => const PageViewScreen());
                                        }
                                      } on FirebaseAuthException catch (error) {
                                        log("Code: ${error.code}");
                                        log("Message: ${error.message!}");
                                      }
                                    } else {
                                      log('error wrong sms');
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  } else {
                                    log('some digit is empty');
                                    setState(() {
                                      loading = false;
                                    });
                                  }
                                },
                              )
                            : Lottie.asset('assets/animations/linear_loading.json', width: 140, height: 140);
                      }),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
