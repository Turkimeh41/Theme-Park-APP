import 'package:flutter/material.dart';
import 'package:final_project/Provider/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({required this.user, super.key});
  final User user;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Account',
            style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
          ),
        ),
        body: Container(
            color: const Color.fromARGB(255, 236, 220, 220),
            width: dw,
            height: dh,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: ListView(children: [
                const SizedBox(height: 50),
                Text(
                  'Personal Information',
                  style: GoogleFonts.signika(color: Colors.black, fontSize: 24),
                )
              ]),
            )));
  }
}
