import 'dart:developer';

import 'package:final_project/Auth_Screens/Register_Screen/verifynumberscreen.dart';
import 'package:final_project/Handler/cloud_handler.dart';
import 'package:final_project/Provider/userauth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:final_project/Customs/gradientbutton.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class RegisterTextFields extends StatefulWidget {
  const RegisterTextFields({required this.slideAnimation, super.key});
  final Animation<Offset> slideAnimation;

  @override
  State<RegisterTextFields> createState() => _RegisterTextFieldsState();
}

class _RegisterTextFieldsState extends State<RegisterTextFields> with TickerProviderStateMixin {
  final key = GlobalKey<FormState>();
  late AnimationController firstFieldsController;
  late AnimationController secondFieldsController;
  late Animation<double> firstFieldsAnimation;
  late Animation<double> secondFieldsAnimation;
  late Animation<Color?> femalecolorAnimation;
  late Animation<Color?> malecolorAnimation;
  late AnimationController femaleController;
  late AnimationController maleController;
  late FocusNode userFocus;
  late FocusNode passFocus;
  late FocusNode confirmpassFocus;
  late FocusNode firstFocus;
  late FocusNode lastFocus;
  late FocusNode emailFocus;
  late FocusNode phoneFocus;
  bool rememberMe = false;
  int state = 0;
  int buttonState = 0;
  bool loading = false;
  var maskFormatter = MaskTextInputFormatter(mask: '## ### ####');

  @override
  void initState() {
    firstFieldsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    secondFieldsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    maleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    femaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));

    malecolorAnimation = ColorTween(begin: const Color.fromARGB(255, 102, 102, 102), end: Colors.blue).animate(CurvedAnimation(parent: maleController, curve: Curves.linear));
    femalecolorAnimation = ColorTween(begin: const Color.fromARGB(255, 109, 108, 108), end: Colors.pink).animate(CurvedAnimation(parent: femaleController, curve: Curves.linear));
    firstFieldsAnimation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: firstFieldsController, curve: Curves.linear));
    secondFieldsAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: secondFieldsController, curve: Curves.linear));

    userFocus = FocusNode();
    passFocus = FocusNode();
    firstFocus = FocusNode();
    lastFocus = FocusNode();
    confirmpassFocus = FocusNode();
    emailFocus = FocusNode();
    phoneFocus = FocusNode();

    passFocus.addListener(() {
      setState(() {});
    });
    userFocus.addListener(() {
      setState(() {});
    });
    firstFocus.addListener(() {
      setState(() {});
    });
    lastFocus.addListener(() {
      setState(() {});
    });
    maleController.addListener(() {
      setState(() {});
    });
    femaleController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    femaleController.dispose();
    maleController.dispose();
    firstFieldsController.dispose();
    secondFieldsController.dispose();

    super.dispose();
  }

  bool validateAndSave() {
    if (!key.currentState!.validate()) {
      return false;
    }
    key.currentState!.save();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    final insRegUser = Provider.of<RegUser>(context, listen: false);
    return SlideTransition(
      position: widget.slideAnimation,
      child: Form(
          key: key,
          //COLUMN 1 FOR STATE 0 , COLUMN 2 FOR STATE 1
          child: SizedBox(
            width: dw,
            height: dh,
            child: Stack(children: [
              Positioned(
                top: dh * 0.3,
                left: dw * 0.04,
                child: Row(
                  children: [
                    SizedBox(
                        width: dw * 0.283,
                        child: const Divider(
                          thickness: 1.5,
                        )),
                    SizedBox(
                      width: dw * 0.03,
                    ),
                    Text(
                      'Registration',
                      style: GoogleFonts.acme(fontSize: 22),
                    ),
                    SizedBox(
                      width: dw * 0.03,
                    ),
                    SizedBox(
                        width: dw * 0.27,
                        child: const Divider(
                          thickness: 1.5,
                        )),
                  ],
                ),
              ),
              Positioned(
                bottom: dh * 0.2,
                left: dw * 0.06,
                child: Visibility(
                  maintainState: true,
                  visible: state == 0,
                  child: FadeTransition(
                    opacity: firstFieldsAnimation,
                    child: Column(children: [
                      //FIRST NAME
                      Row(children: [
                        SizedBox(
                          height: 0.08 * dh,
                          width: dw * 0.42,
                          child: TextFormField(
                              initialValue: insRegUser.firstName,
                              onChanged: (value) {
                                insRegUser.firstName = value;
                              },
                              style: GoogleFonts.alef(fontSize: 16),
                              focusNode: firstFocus,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.supervised_user_circle,
                                  size: 28,
                                  color: firstFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                ),
                                filled: true,
                                fillColor: const Color.fromARGB(255, 224, 224, 224),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                labelText: 'First Name',
                                hintStyle: const TextStyle(color: Color.fromARGB(255, 110, 30, 63)),
                                labelStyle: GoogleFonts.acme(
                                    fontSize: firstFocus.hasFocus ? 22 : 16, color: firstFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                              )),
                        ),
                        SizedBox(
                          width: dw * 0.03,
                        ),

                        //LAST NAME
                        SizedBox(
                          height: 0.08 * dh,
                          width: dw * 0.42,
                          child: TextFormField(
                              initialValue: insRegUser.lastName,
                              onChanged: (value) {
                                insRegUser.lastName = value;
                              },
                              style: GoogleFonts.alef(fontSize: 16),
                              focusNode: lastFocus,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.supervised_user_circle,
                                  size: 28,
                                  color: lastFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                ),
                                filled: true,
                                fillColor: const Color.fromARGB(255, 224, 224, 224),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                labelText: 'Last Name',
                                hintStyle: const TextStyle(color: Color.fromARGB(255, 110, 30, 63)),
                                labelStyle: GoogleFonts.acme(
                                    fontSize: lastFocus.hasFocus ? 22 : 16, color: lastFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                              )),
                        ),
                      ]),

                      SizedBox(
                        height: dh * 0.02,
                      ),

                      SizedBox(
                        width: dw * 0.87,
                        child: Column(children: [
                          //USERNAME

                          SizedBox(
                            height: dh * 0.1,
                            child: StatefulBuilder(builder: (context, buildState) {
                              return TextFormField(
                                  validator: (value) => insRegUser.validateUser(),
                                  initialValue: insRegUser.username,
                                  onChanged: (value) {
                                    if (insRegUser.userError != null) {
                                      buildState(() {
                                        insRegUser.userError = null;
                                      });
                                    }
                                    insRegUser.username = value;
                                  },
                                  style: GoogleFonts.alef(fontSize: 18),
                                  focusNode: userFocus,
                                  decoration: InputDecoration(
                                    errorText: insRegUser.userError,
                                    prefixIcon: Icon(
                                      Icons.verified_user_outlined,
                                      size: 28,
                                      color: userFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 224, 224, 224),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    labelText: 'Username',
                                    errorStyle: const TextStyle(fontSize: 10),
                                    labelStyle: GoogleFonts.acme(
                                        fontSize: userFocus.hasFocus ? 22 : 16, color: userFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                                  ));
                            }),
                          ),

                          SizedBox(
                            height: dh * 0.03,
                          ),

                          //PASSWORD
                          SizedBox(
                            height: dh * 0.09,
                            child: StatefulBuilder(builder: (context, buildState) {
                              return TextFormField(
                                  validator: (value) => insRegUser.validatePass(),
                                  initialValue: insRegUser.password,
                                  onChanged: (value) {
                                    if (insRegUser.passError != null) {
                                      buildState(() {
                                        insRegUser.passError = null;
                                      });
                                    }
                                    insRegUser.password = value;
                                  },
                                  style: GoogleFonts.alef(fontSize: 18),
                                  obscureText: true,
                                  focusNode: passFocus,
                                  decoration: InputDecoration(
                                    errorText: insRegUser.passError,
                                    prefixIcon: Icon(
                                      Icons.lock_sharp,
                                      size: 28,
                                      color: passFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 224, 224, 224),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorStyle: const TextStyle(fontSize: 9),
                                    labelText: 'Password',
                                    labelStyle: GoogleFonts.acme(
                                        fontSize: passFocus.hasFocus ? 22 : 16, color: passFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                                  ));
                            }),
                          ),

                          SizedBox(
                            height: dh * 0.03,
                          ),
                          //CONFIRM PASSWORD
                          SizedBox(
                            height: dh * 0.09,
                            child: StatefulBuilder(builder: (context, buildState) {
                              return TextFormField(
                                  initialValue: insRegUser.confirmedPass,
                                  validator: (value) => insRegUser.validateConfirmPass(),
                                  onChanged: (value) {
                                    if (insRegUser.rePassError != null) {
                                      buildState(() {
                                        insRegUser.rePassError = null;
                                      });
                                    }
                                    insRegUser.confirmedPass = value;
                                  },
                                  style: GoogleFonts.alef(fontSize: 18),
                                  obscureText: true,
                                  focusNode: confirmpassFocus,
                                  decoration: InputDecoration(
                                    errorText: insRegUser.rePassError,
                                    prefixIcon: Icon(
                                      Icons.lock_sharp,
                                      size: 28,
                                      color: confirmpassFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 224, 224, 224),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    labelText: 'Confirm Password',
                                    errorStyle: const TextStyle(fontSize: 9),
                                    labelStyle: GoogleFonts.acme(
                                        fontSize: confirmpassFocus.hasFocus ? 22 : 16,
                                        color: confirmpassFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                                  ));
                            }),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
              //SECOND COLUMN STATE
              Positioned(
                bottom: dh * 0.18,
                left: dw * 0.08,
                child: Visibility(
                  maintainState: true,
                  visible: state == 1,
                  child: FadeTransition(
                    opacity: secondFieldsAnimation,
                    child: SizedBox(
                      width: dw * 0.83,
                      child: Column(
                        children: [
                          SizedBox(
                            height: dh * 0.11,
                            //EMAIL ADDRESS
                            child: StatefulBuilder(builder: (context, buildState) {
                              return TextFormField(
                                  validator: (value) => insRegUser.validateEmail(),
                                  keyboardType: TextInputType.emailAddress,
                                  initialValue: insRegUser.emailAddress,
                                  onChanged: (value) {
                                    if (insRegUser.emailError != null) {
                                      buildState(() {
                                        insRegUser.emailError = null;
                                      });
                                    }
                                    insRegUser.emailAddress = value;
                                  },
                                  style: GoogleFonts.alef(fontSize: 18),
                                  focusNode: emailFocus,
                                  decoration: InputDecoration(
                                    errorText: insRegUser.emailError,
                                    prefixIcon: Icon(
                                      Icons.email,
                                      size: 28,
                                      color: emailFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 224, 224, 224),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorStyle: const TextStyle(fontSize: 10),
                                    labelText: 'Email Address',
                                    labelStyle: GoogleFonts.acme(
                                        fontSize: emailFocus.hasFocus ? 22 : 16, color: emailFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                                  ));
                            }),
                          ),
                          SizedBox(
                            height: dh * 0.015,
                          ),
                          //Phone Number
                          SizedBox(
                            height: dh * 0.11,
                            child: StatefulBuilder(builder: (context, buildState) {
                              return TextFormField(
                                  validator: (value) => insRegUser.validatePhoneNumber(),
                                  inputFormatters: [maskFormatter],
                                  keyboardType: TextInputType.number,
                                  initialValue: insRegUser.phonenumber,
                                  onChanged: (value) {
                                    if (insRegUser.phoneError != null) {
                                      buildState(() {
                                        insRegUser.phoneError = null;
                                      });
                                    }
                                    insRegUser.phonenumber = value;
                                  },
                                  style: GoogleFonts.alef(fontSize: 18),
                                  focusNode: phoneFocus,
                                  decoration: InputDecoration(
                                    errorText: insRegUser.phoneError,
                                    prefix: Text(
                                      '+966  ',
                                      style: TextStyle(color: phoneFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.phone_android_rounded,
                                      size: 24,
                                      color: phoneFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 224, 224, 224),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    errorStyle: const TextStyle(fontSize: 9),
                                    labelText: 'Phone Number',
                                    labelStyle: GoogleFonts.acme(
                                        fontSize: phoneFocus.hasFocus ? 22 : 16, color: phoneFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                                  ));
                            }),
                          ),
                          SizedBox(
                            height: dh * 0.01,
                          ),
                          SizedBox(
                            width: dw * 0.8,
                            height: dh * 0.05,
                            child: Text(
                              'About You?',
                              style: GoogleFonts.acme(fontSize: 16),
                            ),
                          ),
                          //Gender SWITCHER
                          SizedBox(
                            child: Row(children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    insRegUser.gender = 0;
                                    maleController.forward();
                                    femaleController.reverse();
                                  });
                                },
                                child: Column(children: [
                                  Icon(
                                    Icons.male,
                                    color: malecolorAnimation.value,
                                  ),
                                  Image.asset(
                                    'assets/images/male.png',
                                    color: malecolorAnimation.value,
                                    width: 96,
                                    height: 96,
                                  )
                                ]),
                              ),
                              SizedBox(
                                width: dw * 0.3,
                              ),
                              SizedBox(
                                child: InkWell(
                                  onTap: () {
                                    insRegUser.gender = 1;
                                    femaleController.forward();
                                    maleController.reverse();
                                  },
                                  child: Column(children: [
                                    Icon(
                                      Icons.female,
                                      color: femalecolorAnimation.value,
                                    ),
                                    Image.asset(
                                      'assets/images/female.png',
                                      color: femalecolorAnimation.value,
                                      width: 96,
                                      height: 96,
                                    )
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //BACK AND NEXT BUTTONS
              Positioned(
                bottom: dh * 0.1,
                left: dw * 0.07,
                child: SizedBox(
                  height: dh * 0.07,
                  width: dw * 0.84,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatefulBuilder(builder: (context, changeState) {
                        return InkWell(
                          onTap: buttonState == 1
                              ? () {
                                  changeState(
                                    () {
                                      buttonState = 0;
                                    },
                                  );
                                  secondFieldsController.reverse().then((_) => {
                                        setState(() {
                                          state = 0;
                                          firstFieldsController.reverse();
                                        })
                                      });
                                }
                              : null,
                          child: Row(
                            children: buttonState == 1
                                ? [
                                    Transform.scale(
                                      scaleX: -1,
                                      child: const Icon(
                                        Icons.arrow_right_alt,
                                        color: Colors.amber,
                                        size: 36,
                                      ),
                                    ),
                                    Text(
                                      'Back',
                                      style: GoogleFonts.acme(color: Colors.amber, fontSize: 19, fontWeight: FontWeight.bold),
                                    ),
                                  ]
                                : [const SizedBox()],
                          ),
                        );
                      }),
                      StatefulBuilder(builder: (context, changeState) {
                        return InkWell(
                          splashColor: Colors.red,
                          onTap: buttonState == 0
                              ? () async {
                                  changeState(() {
                                    buttonState = 1;
                                  });
                                  firstFieldsController.forward().then((_) => {
                                        setState(() {
                                          state = 1;
                                          secondFieldsController.forward();
                                        })
                                      });
                                }
                              : null,
                          child: Row(
                            children: buttonState == 0
                                ? [
                                    Text(
                                      'Next',
                                      style: GoogleFonts.acme(color: Colors.amber, fontSize: 19, fontWeight: FontWeight.bold),
                                    ),
                                    const Icon(
                                      Icons.arrow_right_alt,
                                      color: Colors.amber,
                                      size: 36,
                                    )
                                  ]
                                : [const SizedBox()],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
              state == 1
                  ? StatefulBuilder(builder: (context, changeLoading) {
                      return Positioned(
                          bottom: loading == false ? dh * 0.10 : dh * 0.05,
                          right: loading == false ? dw * 0.07 : dw * 0.1,
                          child: loading == false
                              //
                              ? NiceButtons(
                                  progress: false,
                                  borderColor: Colors.amber[800]!,
                                  startColor: Colors.amber,
                                  endColor: Colors.amber[800]!,
                                  gradientOrientation: GradientOrientation.Horizontal,
                                  stretch: false,
                                  width: dw * 0.56,
                                  height: dh * 0.06,
                                  onTap: (_) async {
                                    //set state of the statefulbuilder
                                    changeLoading(
                                      () {
                                        loading = true;
                                      },
                                    );
                                    if (validateAndSave()) {
                                      try {
                                        log('checking if an account exists...');
                                        await CloudHandler.userExists(insRegUser.username!, insRegUser.emailAddress!, insRegUser.phonenumber!);
                                        log('User doesn\'t exists!, good.');
                                        String smsCode = await CloudHandler.sendSMSTwilio(insRegUser.phonenumber!);
                                        log('Message should be sent!');
                                        Get.to(() => VerifyNumber(insRegUser, smsCode));
                                      } on FirebaseFunctionsException catch (error) {
                                        setState(() {
                                          log(error.message!);
                                          log(error.code);
                                          insRegUser.showErrors(error.message!);
                                        });
                                      }
                                    }
                                    //set state of the statefulbuilder
                                    changeLoading(
                                      () {
                                        loading = false;
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Register',
                                    style: GoogleFonts.acme(color: Colors.white, fontSize: 27),
                                  ),
                                )
                              : Lottie.asset('assets/animations/linear_loading.json', width: 140, height: 140));
                    })
                  : const SizedBox()
            ]),
          )),
    );
  }
}
