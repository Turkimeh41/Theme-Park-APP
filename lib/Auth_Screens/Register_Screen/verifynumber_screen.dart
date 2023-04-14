import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../Handler/verify_handler.dart';

class VerifyNumber extends StatefulWidget {
  const VerifyNumber({super.key});
  @override
  State<VerifyNumber> createState() => _VerifyNumberState();
}

class _VerifyNumberState extends State<VerifyNumber> with TickerProviderStateMixin {
  var maskFormatter = MaskTextInputFormatter(mask: '#');

  bool visible = false;

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

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: VerifyHandler.key,
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
                        TextSpan(text: '(+966) ${VerifyHandler.formatphone(VerifyHandler.user.phonenumber!)}', style: GoogleFonts.acme(color: const Color.fromARGB(255, 245, 228, 172), fontSize: 24))
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
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: VerifyHandler.error1 ? Border.all(color: Colors.red, width: 2.5) : null),
                              child: TextFormField(
                                initialValue: VerifyHandler.digit1,
                                validator: (value) => VerifyHandler.fieldValidator(1, value),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                                inputFormatters: [maskFormatter],
                                style: GoogleFonts.acme(fontSize: 42),
                                onChanged: (value) {
                                  VerifyHandler.digit1 = value;
                                  if (VerifyHandler.error1) {
                                    setStateful(() {
                                      VerifyHandler.error1 = false;
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
                                decoration:
                                    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: VerifyHandler.error2 ? Border.all(color: Colors.red, width: 2.5) : null),
                                child: TextFormField(
                                  initialValue: VerifyHandler.digit2,
                                  validator: (value) => VerifyHandler.fieldValidator(2, value),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                                  ),
                                  inputFormatters: [maskFormatter],
                                  style: GoogleFonts.acme(fontSize: 42),
                                  onChanged: (value) {
                                    VerifyHandler.digit2 = value;
                                    setStateful(() {
                                      VerifyHandler.error2 = false;
                                    });
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
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: VerifyHandler.error3 ? Border.all(color: Colors.red, width: 2.5) : null),
                              child: TextFormField(
                                validator: (value) => VerifyHandler.fieldValidator(3, value!),
                                initialValue: VerifyHandler.digit3,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide.none)),
                                inputFormatters: [maskFormatter],
                                style: GoogleFonts.acme(fontSize: 42),
                                onChanged: (value) {
                                  VerifyHandler.digit3 = value;
                                  setStateful(() {
                                    VerifyHandler.error3 = false;
                                  });
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
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: VerifyHandler.error4 ? Border.all(color: Colors.red, width: 2.5) : null),
                              child: TextFormField(
                                initialValue: VerifyHandler.digit4,
                                validator: (value) => VerifyHandler.fieldValidator(4, value),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                                ),
                                inputFormatters: [maskFormatter],
                                style: GoogleFonts.acme(fontSize: 42),
                                onChanged: (value) {
                                  VerifyHandler.digit4 = value;
                                  setStateful(() {
                                    VerifyHandler.error4 = false;
                                  });

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
                    return StatefulBuilder(builder: (context, StateSetter builderState) {
                      return Positioned(
                        top: VerifyHandler.loading == false ? sizeAnimation.value.height * 0.85 + buttonMargin : sizeAnimation.value.height * 0.78 + buttonMargin,
                        left: VerifyHandler.loading == false ? dw * 0.245 : dw * 0.325,
                        child: !VerifyHandler.loading
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
                                onTap: (_) => VerifyHandler.verify(builderState, setState),
                              )
                            : Lottie.asset('assets/animations/linear_loading_amber.json', width: 140, height: 140),
                      );
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
