import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/ANONYMOUS_SCREEN/anonymous_widget.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/ANONYMOUS_SCREEN/qr_view_v2.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AnonymousScreen extends StatefulWidget {
  const AnonymousScreen({super.key});

  @override
  State<AnonymousScreen> createState() => _AnonymousScreenState();
}

class _AnonymousScreenState extends State<AnonymousScreen> {
  late AnonymousUsers _anonymousUsers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final anonymous = Provider.of<AnonymousUsers>(context, listen: false);
    // Save a reference to the ancestor in a local variable
    _anonymousUsers = anonymous;
  }

  @override
  void dispose() {
    _anonymousUsers.currentUserID = null;
    _anonymousUsers.userAnonymousLength = null;
    _anonymousUsers.confirm = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anonymous = Provider.of<AnonymousUsers>(context);
    final anonymousList = anonymous.anonymousUsers;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 235, 235),
      body: Stack(alignment: Alignment.center, children: [
        Positioned(
            top: 75,
            left: 30,
            child: RichText(
                text: TextSpan(
              text: 'Anonymous Users\n',
              style: GoogleFonts.signika(color: Colors.grey[800], fontSize: 22.5, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: anonymous.confirm
                        ? ' Tap any Anonymous QR code to assign\n to that provider account depending\n to how many that user wants, Maximum 3 Allowed!'
                        : ' Start by scanning a qr code of a user,\n  then check if it\'s applicable to add\n  more users to that account',
                    style: GoogleFonts.signika(fontSize: 13, color: Colors.grey[600])),
              ],
            ))),
        Positioned(
          top: 175,
          child: anonymous.confirm
              ? Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${3 - anonymous.userAnonymousLength!}/3 ${anonymous.userAnonymousLength == 3 ? 'Unavailiable, Can\'t assign more\n Anonymous QRs to that Account!' : 'Availiable, The User account\n can be assigned with QR codes'}',
                        style: GoogleFonts.signika(
                            color: anonymous.userAnonymousLength == 3 ? const Color.fromARGB(255, 141, 26, 18) : const Color.fromARGB(255, 26, 148, 30), fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: const Color.fromARGB(255, 136, 135, 135), borderRadius: BorderRadius.circular(12)),
                      height: 300,
                      width: 250,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return AnonymousWidget(anonymous: anonymousList[index]);
                        },
                        itemCount: anonymousList.length,
                        separatorBuilder: (context, index) {
                          return Divider(height: 1, color: Colors.grey[300]);
                        },
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
        Positioned(
            bottom: 25,
            child: GestureDetector(
              onTap: () => Get.to(() => const QrViewScreen2()),
              child: Image.asset(
                'assets/images/scanning.png',
                width: 82,
                height: 82,
              ),
            )),
      ]),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
        centerTitle: true,
        title: Text(
          'Anonymous Users',
          style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
