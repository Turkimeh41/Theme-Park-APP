import 'package:final_project/Main_Menu/ACCOUNT_SCREEN/personal_information.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  static const routeName = '/account';

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late PageController pageController;
  int page = 0;
  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        body: Stack(
          alignment: Alignment.center,
          children: [
            PageView(
              onPageChanged: (value) {
                setState(() {
                  page = value;
                });
              },
              controller: pageController,
              scrollDirection: Axis.horizontal,
              children: [
                const PersonalInformation(),
                SizedBox(
                  width: dw,
                  height: dh,
                )
              ],
            ),
            Positioned(
              left: page == 0 ? null : 10,
              right: page == 1 ? null : 10,
              child: IconButton(
                  onPressed: () {
                    pageController.animateToPage(page == 0 ? 1 : 0, duration: const Duration(milliseconds: 250), curve: Curves.linear);
                  },
                  icon: Transform.scale(
                    scaleX: page == 0 ? 1 : -1,
                    child: const Icon(
                      size: 46,
                      Icons.arrow_right_alt_outlined,
                      color: Color.fromARGB(255, 102, 5, 50),
                    ),
                  )),
            )
          ],
        ));
  }
}
