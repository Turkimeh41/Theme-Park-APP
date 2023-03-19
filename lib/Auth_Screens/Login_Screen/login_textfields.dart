import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginTextFields extends StatefulWidget {
  const LoginTextFields({super.key});

  @override
  State<LoginTextFields> createState() => _LoginTextFieldsState();
}

class _LoginTextFieldsState extends State<LoginTextFields> {
  final key = GlobalKey<FormState>();
  late FocusNode userFocus;
  late FocusNode passFocus;
  bool rememberMe = false;
  @override
  void initState() {
    userFocus = FocusNode();
    passFocus = FocusNode();
    passFocus.addListener(() {
      setState(() {});
    });
    userFocus.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Form(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 0.1 * dh,
            width: dw * 0.75,
            child: TextFormField(
                style: GoogleFonts.alef(fontSize: 18),
                focusNode: userFocus,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.supervised_user_circle,
                    size: userFocus.hasFocus ? 36 : 28,
                    color: userFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 224, 224, 224),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  labelText: 'Username',
                  labelStyle: GoogleFonts.acme(fontSize: userFocus.hasFocus ? 24 : 18, color: userFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey),
                )),
          ),
          SizedBox(
            height: dh * 0.03,
          ),
          SizedBox(
            width: dw * 0.75,
            child: TextFormField(
                style: GoogleFonts.alef(fontSize: 18),
                obscureText: true,
                focusNode: passFocus,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_sharp,
                    size: passFocus.hasFocus ? 36 : 28,
                    color: passFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 224, 224, 224),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  labelText: 'Password',
                  labelStyle: GoogleFonts.acme(fontSize: passFocus.hasFocus ? 24 : 18, color: passFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey),
                )),
          ),
          SizedBox(
            height: dh * 0.015,
          ),
          Row(
            children: [
              Transform.scale(
                scaleX: 1.25,
                scaleY: 1.25,
                child: Checkbox(
                  activeColor: const Color.fromARGB(255, 110, 30, 63),
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value!;
                      log('$rememberMe');
                    });
                  },
                ),
              ),
              Text(
                'Remember me?',
                style: GoogleFonts.acme(fontSize: 18),
              )
            ],
          )
        ],
      ),
    );
  }
}
