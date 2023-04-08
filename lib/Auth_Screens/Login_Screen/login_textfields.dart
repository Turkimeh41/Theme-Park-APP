import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:final_project/Provider/userauth_provider.dart';

class LoginTextFields extends StatefulWidget {
  const LoginTextFields({super.key});

  @override
  State<LoginTextFields> createState() => _LoginTextFieldsState();
}

class _LoginTextFieldsState extends State<LoginTextFields> {
  final key = GlobalKey<FormState>();
  late FocusNode userFocus;
  late FocusNode passFocus;
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
    return Consumer<LogUser>(
      builder: (context, insLogUser, child) => Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 0.1 * dh,
              width: dw * 0.75,
              child: StatefulBuilder(builder: (context, buildState) {
                return TextFormField(
                    onChanged: (value) {
                      if (insLogUser.userError != null) {
                        buildState(() {
                          insLogUser.userError = null;
                        });
                      }
                      insLogUser.username = value;
                    },
                    style: GoogleFonts.alef(fontSize: 18),
                    focusNode: userFocus,
                    decoration: InputDecoration(
                      errorText: insLogUser.userError,
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.supervised_user_circle,
                        size: userFocus.hasFocus ? 36 : 28,
                        color: userFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 224, 224, 224),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.red, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.red, width: 1)),
                      errorStyle: const TextStyle(fontSize: 13),
                      labelText: 'Username',
                      labelStyle: GoogleFonts.acme(fontSize: userFocus.hasFocus ? 28 : 20, color: userFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey),
                    ));
              }),
            ),
            SizedBox(
              height: dh * 0.02,
            ),
            SizedBox(
              height: 0.1 * dh,
              width: dw * 0.75,
              child: StatefulBuilder(builder: (context, buildState) {
                return TextFormField(
                    onChanged: (value) {
                      if (insLogUser.passError != null) {
                        buildState(() {
                          insLogUser.passError = null;
                        });
                      }
                      insLogUser.password = value;
                    },
                    style: GoogleFonts.alef(fontSize: 18),
                    obscureText: true,
                    focusNode: passFocus,
                    decoration: InputDecoration(
                      errorText: insLogUser.passError,
                      prefixIcon: Icon(
                        Icons.lock_sharp,
                        size: passFocus.hasFocus ? 36 : 28,
                        color: passFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 224, 224, 224),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.red, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.red, width: 1)),
                      errorStyle: const TextStyle(fontSize: 13),
                      labelText: 'Password',
                      labelStyle: GoogleFonts.acme(fontSize: passFocus.hasFocus ? 26 : 20, color: passFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : Colors.grey),
                    ));
              }),
            ),
            SizedBox(
              height: dh * 0.001,
            ),
          ],
        ),
      ),
    );
  }
}
