import 'package:final_project/Customs/gradientbutton.dart';
import 'package:final_project/Page_View/pageview_screen.dart';
import 'package:final_project/Provider/cloud_handler.dart';
import 'package:final_project/Main_Menu/mainmenu_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Provider/userauth_provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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

    KeyboardVisibilityController().onChange.listen((visible) {
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
        buttonMargin = buttonMargin + 3.4;
      } else if (sizeController.status == AnimationStatus.reverse) {
        textMargin = textMargin - 0.8;
        otpMargin = otpMargin - 2.8;
        buttonMargin = buttonMargin - 3.4;
      }
    });
    //invokes whenever the status changes
    sizeController.addStatusListener((status) {
      if (sizeController.status == AnimationStatus.dismissed) {
        textMargin = 0;
        otpMargin = 0;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    fadeController.dispose();
    sizeController.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    bool isvalid = key.currentState!.validate();
    if (!isvalid) {
      return false;
    }
    key.currentState!.save();
    return true;
  }

  String formatphone(String phone) {
    final last4Digits = phone.substring(phone.length - 4);
    final asterisks = '*' * (phone.length - 4);
    return '$asterisks$last4Digits';
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
                top: 0 * dh * 0.04,
                left: 0,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 36,
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
                        TextSpan(text: 'We\'ve Sent a verifcation code to the number: ', style: GoogleFonts.roboto(fontSize: 18)),
                        const TextSpan(text: '\n'), //${formatphone(widget.user.phonenumber!)}
                        TextSpan(text: '(+966) 549664323', style: GoogleFonts.acme(color: const Color.fromARGB(255, 245, 228, 172), fontSize: 24))
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
                          Container(
                            alignment: Alignment.center,
                            width: dw * 0.16,
                            height: dh * 0.09,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              onSaved: (value) {
                                digit1 = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                              inputFormatters: [maskFormatter],
                              style: const TextStyle(fontSize: 36),
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: dw * 0.16,
                            height: dh * 0.09,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              onSaved: (value) {
                                digit2 = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                              inputFormatters: [maskFormatter],
                              style: const TextStyle(fontSize: 36),
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: dw * 0.16,
                            height: dh * 0.09,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              onSaved: (value) {
                                digit3 = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                              inputFormatters: [maskFormatter],
                              style: const TextStyle(fontSize: 36),
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: dw * 0.16,
                            height: dh * 0.09,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              onSaved: (value) {
                                digit4 = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                              inputFormatters: [maskFormatter],
                              style: const TextStyle(fontSize: 36),
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                        ],
                      ));
                },
              ),
              //Submit Button
              AnimatedBuilder(
                  animation: sizeController,
                  builder: (context, child) {
                    return Positioned(
                      top: sizeAnimation.value.height * 0.7 + buttonMargin,
                      left: dw * 0.3,
                      child: StatefulBuilder(builder: (context, builderState) {
                        return !loading
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: dh * 0.15,
                                  ),
                                  GradientButton(
                                    style: GoogleFonts.acme(fontSize: 28, color: Colors.white),
                                    gradient: LinearGradient(colors: [Colors.amber, Colors.amber[700]!]),
                                    height: 50,
                                    width: 150,
                                    radius: 15,
                                    'Submit',
                                    onTap: () async {
                                      if (validateAndSave()) {
                                        builderState(() {
                                          loading = true;
                                        });
                                        smsInput = digit1! + digit2! + digit3! + digit4!;
                                        log(smsInput);
                                        log(widget.smsCode);
                                        if (smsInput == widget.smsCode) {
                                          log('adding User...');
                                          try {
                                            String token = await CloudHandler.addUser(widget.user.username!, widget.user.password!, widget.user.firstName!, widget.user.lastName!,
                                                widget.user.emailAddress!, widget.user.phonenumber!, widget.user.gender!);
                                            log('Success!');
                                            builderState(() {
                                              loading = false;
                                            });
                                            await FirebaseAuth.instance.signInWithCustomToken(token);
                                            log('Signing in...');
                                            final _pref = await SharedPreferences.getInstance();
                                            bool intro = _pref.getBool('intro') ?? false;
                                            if (intro) {
                                              Get.off(() => const PageViewScreen());
                                            } else {
                                              Get.off(() => const MainMenuScreen());
                                            }
                                          } on FirebaseAuthException catch (error) {
                                            log("Code: ${error.code}");
                                            log("Message: ${error.message!}");
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Lottie.asset('assets/animations/linear_loading.json', width: 140, height: 140),
                                ],
                              );
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
