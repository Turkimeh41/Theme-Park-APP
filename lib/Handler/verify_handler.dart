// ignore_for_file: use_build_context_synchronously

import 'package:final_project/Exception/sms_exception.dart';
import 'package:final_project/Handler/general_handler.dart';
import 'package:final_project/Handler/user_firebase_handler.dart';

import 'package:final_project/utility_provider.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:final_project/AUTH_SCREEN/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project/USERS/PAGEVIEW_SCREEN/pageview_screen.dart';
import 'package:get/get.dart';

class VerifyHandler {
  static bool error1 = false;
  static bool error2 = false;
  static bool error3 = false;
  static bool error4 = false;
  static String? digit1;
  static String? digit2;
  static String? digit3;
  static String? digit4;
  static String smsInput = '';
  static String smsCode = '';
  static final key = GlobalKey<FormState>();
  static bool loading = false;
  static late RegUser user;

  static bool validate() {
    bool isvalid = key.currentState!.validate();
    if (!isvalid) {
      log('user validation: wrong');
      return false;
    }
    log('user validation: correct');
    return true;
  }

  static String? fieldValidator(int field, String? digit) {
    switch (field) {
      case 1:
        if (digit == null) {
          error1 = true;
          return '';
        }
        if (digit.isEmpty) {
          error1 = true;
          return '';
        }
        break;
      case 2:
        if (digit == null) {
          error1 = true;
          return '';
        }
        if (digit.isEmpty) {
          error1 = true;
          return '';
        }
        break;
      case 3:
        if (digit == null) {
          error1 = true;
          return '';
        }
        if (digit.isEmpty) {
          error1 = true;
          return '';
        }
        break;
      case 4:
        if (digit == null) {
          error1 = true;
          return '';
        }
        if (digit.isEmpty) {
          error4 = true;
          return '';
        }
    }
    return null;
  }

  static String formatphone(String phone) {
    final last4Digits = phone.substring(phone.length - 4);
    final asterisks = '*' * (phone.length - 4);
    return '$asterisks$last4Digits';
  }

  static Future<void> verify(StateSetter builderState, Function setState, Utility utility, BuildContext context) async {
    if (validate()) {
      builderState(() {
        loading = true;
      });
      smsInput = digit1! + digit2! + digit3! + digit4!;
      if (smsInput == smsCode) {
        log('adding User...');
        try {
          //add user function, will return
          Map<String, dynamic> result = await UserFirebaseHandler.addUser(user.username!, user.password!, user.firstName!, user.lastName!, user.emailAddress!, user.phonenumber!, user.gender!);
          log('Success!');
          builderState(() {
            loading = false;
          });
          log('Signing in...');

          log('done!');
          final pref = await SharedPreferences.getInstance();
          // ignore: non_constant_identifier_names
          bool intro_done = pref.getBool('intro-done') ?? false;
          log('intro-done: $intro_done');
          await utility.setCurrentUser("user");
          if (intro_done) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            await GeneralHandler.signInWithCustomToken(result['token']!);

            await UserFirebaseHandler.setLastLogin();
          } else {
            Get.off(() => PageViewScreen(customToken: result['token'] as String), transition: Transition.fadeIn);
          }
        } on FirebaseAuthException catch (error) {
          setState(() {
            log("Code: ${error.code}");
            log("Message: ${error.message!}");
            loading = false;
          });
        } catch (error) {
          setState(() {
            loading = false;
          });
        }
      } else {
        setState(() {
          loading = false;
        });
        throw SmsException(code: 'invalid-code', details: "The code that you entered is invalid");
      }
    }
  }
}
