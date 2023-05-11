import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:regexpattern/regexpattern.dart';

class RegUser with ChangeNotifier {
  String? username;
  String? firstName;
  String? lastName;
  String? emailAddress;
  int? gender;
  String? phonenumber;
  int? age;
  String? password;
  String? confirmedPass;

  //Handles all the errors, it Displays the text error from the HTTPS thrown ERRORS or Client side error inputs
  String? userError;
  String? emailError;
  String? phoneError;
  String? passError;
  String? rePassError;

  void showErrors(String message) {
    if (message[0] == 'T') {
      userError = 'this Username already exists in our system.';
    }
    if (message[2] == 'T') {
      phoneError = 'this Phone Number is already affliatied with another account.';
    }
    if (message[4] == 'T') {
      emailError = 'this Email is already affliatied with another account.';
    }
  }

  String? validateUser() {
    if (username == null || username!.isEmpty) {
      userError = 'please fill in the username Field.';
      return 'please fill in the username Field.';
    }
    if (username![0] == '0' ||
        username![0] == '1' ||
        username![0] == '2' ||
        username![0] == '3' ||
        username![0] == '4' ||
        username![0] == '5' ||
        username![0] == '6' ||
        username![0] == '7' ||
        username![0] == '8' ||
        username![0] == '9') {
      userError = 'Error, username cannot starts with a letter.';
      return 'Error, username cannot starts with a letter.';
    } else if (username!.length <= 4) {
      userError = 'Error, username most be longer than 4 letters.';
      return 'Error, username most be longer than 4 letters.';
    }
    userError = null;
    return null;
  }

  String? validatePass() {
    if (password == null || password!.isEmpty) {
      passError = 'please fill in the Password Field.';
      return 'please fill in the Password Field.';
    }
    if (!password!.isPasswordNormal3()) {
      passError = 'Password Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, and Minimum 8 characters.';
      return 'Password Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, and Minimum 8 characters.';
    }
    passError = null;
    return null;
  }

  String? validateConfirmPass() {
    if (confirmedPass == null || confirmedPass!.isEmpty) {
      rePassError = 'Please reconfirm your password.';
      return 'Please reconfirm your password.';
    }
    if (confirmedPass != password) {
      rePassError = 'Confirmed password not correct.';
      return 'Confirmed password not correct.';
    }
    rePassError = null;
    return null;
  }

  String? validateEmail() {
    if (emailAddress == null || emailAddress!.isEmpty) {
      emailError = 'Please fill in the Email Address field.';
      return 'Please fill in the Email Address field.';
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailAddress!)) {
      emailError = 'INVALID, Recheck your email input.';
      return 'INVALID, Recheck your email input.';
    }
    emailError = null;
    return null;
  }

  String? validatePhoneNumber() {
    if (phonenumber == null || phonenumber!.isEmpty) {
      phoneError = 'Please fill in the Phone Number field.';
      return 'Please fill in the Phone Number field.';
    }
    if (phonenumber!.length != 11) {
      phoneError = 'Please Enter a number with 9 digits.';
      return 'Please Enter a number with 9 digits.';
    }
    if (phonenumber!.isNumericOnly) {
      phoneError = 'ERROR, ONLY NUMBERS ARE ACCEPTED.';
      return 'ERROR, ONLY NUMBERS ARE ACCEPTED.';
    }
    phoneError = null;
    return null;
  }
}

class LogUser with ChangeNotifier {
  String? username;
  String? password;
  String? userError;
  String? passError;
  final formKey = GlobalKey<FormState>();

  void showErrors(String message, BuildContext context) {
    if (message == 'Username doesn\'t exists.') {
      userError = message;
    } else if (message == "Password incorrect.") {
      passError = message;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Error: $message',
        style: const TextStyle(color: Colors.red),
      )));
    }
  }

  String? validateUser() {
    if (username == null || username!.isEmpty) {
      userError = 'please fill in the username Field.';
      return 'please fill in the username Field.';
    }
    userError = null;
    return null;
  }

  String? validatePass() {
    if (password == null || password!.isEmpty) {
      passError = 'please fill in the Password Field.';
      return '';
    }
    passError = null;
    return null;
  }

  bool validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    formKey.currentState!.save();
    return true;
  }
}
