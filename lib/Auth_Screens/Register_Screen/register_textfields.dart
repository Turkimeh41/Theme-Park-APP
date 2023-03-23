import 'dart:developer';

import 'package:final_project/Provider/useraddProviders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:final_project/Customs/GradientButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:lottie/lottie.dart';

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
    firstFocus.addListener(() {
      setState(() {});
    });
    lastFocus.addListener(() {
      setState(() {});
    });
    femaleController.addListener(() {
      setState(() {});
    });
    femalecolorAnimation.addListener(() {
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

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    final insRegUserAdd = Provider.of<RegUserAdd>(context, listen: false);
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
                          child: StatefulBuilder(builder: (context, statefulState) {
                            log('REBUILT');
                            firstFocus.addListener(() {
                              statefulState(() {});
                            });
                            return TextFormField(
                                initialValue: insRegUserAdd.firstName,
                                onChanged: (value) {
                                  insRegUserAdd.firstName = value;
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
                                ));
                          }),
                        ),
                        SizedBox(
                          width: dw * 0.03,
                        ),

                        //LAST NAME
                        SizedBox(
                          height: 0.08 * dh,
                          width: dw * 0.42,
                          child: TextFormField(
                              initialValue: insRegUserAdd.lastName,
                              onChanged: (value) {
                                insRegUserAdd.lastName = value;
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
                            child: TextFormField(
                                validator: (value) => insRegUserAdd.validateUser(),
                                initialValue: insRegUserAdd.username,
                                onChanged: (value) {
                                  insRegUserAdd.username = value;
                                },
                                style: GoogleFonts.alef(fontSize: 18),
                                focusNode: userFocus,
                                decoration: InputDecoration(
                                  errorText: insRegUserAdd.userError,
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
                                )),
                          ),

                          SizedBox(
                            height: dh * 0.03,
                          ),

                          //PASSWORD

                          SizedBox(
                            height: dh * 0.09,
                            child: TextFormField(
                                validator: (value) => insRegUserAdd.validatePass(),
                                initialValue: insRegUserAdd.password,
                                onChanged: (value) {
                                  insRegUserAdd.password = value;
                                },
                                style: GoogleFonts.alef(fontSize: 18),
                                obscureText: true,
                                focusNode: passFocus,
                                decoration: InputDecoration(
                                  errorText: insRegUserAdd.passError,
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
                                )),
                          ),

                          SizedBox(
                            height: dh * 0.03,
                          ),

                          //CONFIRM PASSWORD

                          SizedBox(
                            height: dh * 0.09,
                            child: TextFormField(
                                initialValue: insRegUserAdd.confirmedPass,
                                validator: (value) => insRegUserAdd.validateConfirmPass(),
                                onChanged: (value) {
                                  insRegUserAdd.confirmedPass = value;
                                },
                                style: GoogleFonts.alef(fontSize: 18),
                                obscureText: true,
                                focusNode: confirmpassFocus,
                                decoration: InputDecoration(
                                  errorText: insRegUserAdd.rePassError,
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
                                )),
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
                            child: TextFormField(
                                validator: (value) => insRegUserAdd.validateEmail(),
                                keyboardType: TextInputType.emailAddress,
                                initialValue: insRegUserAdd.emailAddress,
                                onChanged: (value) {
                                  insRegUserAdd.emailAddress = value;
                                },
                                style: GoogleFonts.alef(fontSize: 18),
                                focusNode: emailFocus,
                                decoration: InputDecoration(
                                  errorText: insRegUserAdd.emailError,
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
                                )),
                          ),
                          SizedBox(
                            height: dh * 0.015,
                          ),
                          //Phone Number
                          SizedBox(
                            height: dh * 0.11,
                            child: StatefulBuilder(builder: (context, setStater) {
                              return TextFormField(
                                  validator: (value) => insRegUserAdd.validatePhoneNumber(),
                                  inputFormatters: [maskFormatter],
                                  keyboardType: TextInputType.number,
                                  initialValue: insRegUserAdd.phonenumber,
                                  onChanged: (value) {
                                    insRegUserAdd.phonenumber = value;
                                  },
                                  style: GoogleFonts.alef(fontSize: 18),
                                  focusNode: phoneFocus,
                                  decoration: InputDecoration(
                                    errorText: insRegUserAdd.phoneError,
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
                                  insRegUserAdd.gender = 0;
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
                                  insRegUserAdd.gender = 1;
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
                          ])),
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
                                  changeState(
                                    () {
                                      buttonState = 1;
                                    },
                                  );

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
                          bottom: loading == false ? dh * 0.11 : dh * 0.05,
                          right: loading == false ? dw * 0.04 : dw * 0.1,
                          child: loading == false
                              ? GradientButton(
                                  style: GoogleFonts.acme(color: Colors.white, fontSize: 27),
                                  width: dw * 0.6,
                                  height: dh * 0.05,
                                  'Register',
                                  onTap: () async {
                                    changeLoading(
                                      () {
                                        loading = true;
                                      },
                                    );
                                    final isValid = key.currentState!.validate();
                                    if (isValid) {
                                      key.currentState!.save();
                                      final functions = FirebaseFunctions.instanceFor(region: "europe-west1");
                                      try {
                                        final response = await functions.httpsCallable('addUser').call({
                                          'username': insRegUserAdd.username,
                                          'password': insRegUserAdd.password,
                                          'first_name': insRegUserAdd.firstName,
                                          'last_name': insRegUserAdd.lastName,
                                          'emailAddress': insRegUserAdd.emailAddress,
                                          'gender': insRegUserAdd.gender,
                                          'number': insRegUserAdd.phonenumber
                                        });
                                        FirebaseAuth.instance.signInWithCustomToken(response.data['token']);
                                      } on FirebaseFunctionsException catch (error) {
                                        setState(() {
                                          log(error.message!);
                                          log(error.code);
                                          insRegUserAdd.showErrors(error.message!);
                                        });
                                      }
                                    }
                                    changeLoading(
                                      () {
                                        loading = false;
                                      },
                                    );
                                  },
                                  radius: 20,
                                  gradient: LinearGradient(colors: [Colors.amber, Colors.amber[800]!]),
                                )
                              : Lottie.asset('assets/animations/linear_loading.json', width: 140, height: 140));
                    })
                  : const SizedBox()
            ]),
          )),
    );
  }
}
