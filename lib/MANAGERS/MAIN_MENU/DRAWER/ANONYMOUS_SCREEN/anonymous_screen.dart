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
    final insAnonymous = Provider.of<AnonymousUsers>(context);
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
        centerTitle: true,
        title: Text(
          'Anonymous Users',
          style: GoogleFonts.signika(color: Colors.white, fontSize: 18),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 243, 235, 235),
      body: RefreshIndicator(
        color: Colors.amber,
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
            future: insAnonymous.fetchAnonymousUnassignedQR(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
                );
              } else {
                final anonymousList = insAnonymous.anonymousUsers;

                return ListView(padding: const EdgeInsets.only(top: 36, left: 12, right: 12), children: [
                  Text('Anonymous QR codes', style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 22.5, fontWeight: FontWeight.bold)),
                  Text(
                    'Assign a new dedicated anonymous\n   with his balance and name from here!',
                    style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(color: const Color.fromARGB(255, 228, 216, 216), borderRadius: BorderRadius.circular(12)),
                    height: 300,
                    child: ListView.separated(
                      itemCount: anonymousList.length,
                      separatorBuilder: (context, index) {
                        return const Divider(height: 1, color: Color.fromARGB(255, 136, 127, 127));
                      },
                      itemBuilder: (context, index) => AnonymousWidget(anonymous: anonymousList[index], type: 'normal'),
                    ),
                  ),
                  const SizedBox(height: 75),
                  RichText(
                      text: TextSpan(
                    text: 'Family/Friends QR codes\n',
                    style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 22.5, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: insAnonymous.confirm
                              ? ' Tap any Anonymous QR code to assign\n to that provider account depending\n to how many that user wants, Maximum 4 Allowed!'
                              : ' Start by scanning a qr code of a user,\n  then check if it\'s applicable to add\n  more users to that account',
                          style: GoogleFonts.signika(fontSize: 13, color: Theme.of(context).secondaryHeaderColor)),
                    ],
                  )),
                  const SizedBox(height: 40),
                  insAnonymous.confirm
                      ? Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${4 - insAnonymous.userAnonymousLength!}/4 ${insAnonymous.userAnonymousLength == 4 ? 'Unavailiable, Can\'t assign more\n Anonymous QRs to that Account!' : 'Availiable, The User account can be\n    assigned with QR codes'}',
                                style: GoogleFonts.signika(
                                    color: insAnonymous.userAnonymousLength == 4 ? const Color.fromARGB(255, 141, 26, 18) : const Color.fromARGB(255, 26, 148, 30),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              decoration: BoxDecoration(color: const Color.fromARGB(255, 228, 216, 216), borderRadius: BorderRadius.circular(12)),
                              height: 300,
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return AnonymousWidget(anonymous: anonymousList[index], type: "provider");
                                },
                                itemCount: anonymousList.length,
                                separatorBuilder: (context, index) {
                                  return const Divider(height: 1, color: Color.fromARGB(255, 136, 127, 127));
                                },
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(height: 350),
                  GestureDetector(
                    onTap: () => Get.to(() => const QrViewScreen2()),
                    child: Image.asset(
                      'assets/images/scanning.png',
                      width: 82,
                      height: 82,
                    ),
                  ),
                  const SizedBox(height: 30),
                ]);
              }
            }),
      ),
    );
  }
}
