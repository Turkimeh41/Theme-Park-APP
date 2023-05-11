// ignore_for_file: use_build_context_synchronously

import 'package:final_project/Main_Menu/HOME_SCREEN/home_screen.dart';
import 'package:final_project/Main_Menu/QR_SCREEN/qr_view.dart';
import 'package:final_project/Main_Menu/WALLET_SCREEN/wallet_screen.dart';
import 'package:final_project/Main_Menu/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/Provider/user_provider.dart' as u;

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int navChoice = 0;
  @override
  Widget build(BuildContext context) {
    Provider.of<u.User>(context, listen: true);
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
        drawer: const Drawer(
          backgroundColor: Color.fromARGB(255, 243, 235, 235),
          width: 180,
          child: UserDrawer(),
        ),
        appBar: AppBar(
          actions: [
            Theme(
              data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
                popupMenuTheme: const PopupMenuThemeData(color: Color.fromARGB(255, 102, 5, 50)),
                dividerTheme: const DividerThemeData(color: Colors.white),
              ),
              child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: PopupMenuButton<int>(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    itemBuilder: (builderContext) {
                      return [
                        PopupMenuItem<int>(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.settings, color: Colors.white),
                            Text('Settings', style: GoogleFonts.acme(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 16)),
                          ],
                        )),
                        const PopupMenuDivider(
                          height: 20,
                        ),
                        PopupMenuItem<int>(
                            onTap: () async {
                              final pref = await SharedPreferences.getInstance();
                              await pref.remove('remember-me');
                              await FirebaseAuth.instance.signOut();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.logout_outlined, color: Colors.white),
                                Text('Logout', style: GoogleFonts.acme(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 16)),
                              ],
                            )),
                      ];
                    },
                  )),
            )
          ],
        ),
        body: Container(
          color: const Color.fromARGB(255, 243, 235, 235),
          height: dh,
          width: dw,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // NAVIGATION TO THE OTHER SCREENS
              if (navChoice == 0)
                Container(padding: const EdgeInsets.only(bottom: 60), child: const HomeScreen())
              else if (navChoice == 1)
                Container(padding: const EdgeInsets.only(bottom: 60), child: const WalletScreen()),

//CONTAINER THAT DOES THE SHADERMASK
              Positioned(
                  bottom: 0,
                  width: dw,
                  height: 120,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(colors: [Color.fromARGB(255, 87, 0, 41), Color.fromARGB(255, 39, 1, 19), Color.fromARGB(255, 87, 0, 41)]).createShader(bounds);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: dw,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          child: Container(
                            width: 142,
                            height: 142,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )),

              //HOME AND WALLET BUTTONS
              Positioned(
                bottom: 0,
                width: dw,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              navChoice = 0;
                            });
                          },
                          child: SizedBox(
                            height: 75,
                            width: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: navChoice == 0
                                      ? Image.asset(key: const ValueKey("0"), 'assets/images/home.png', width: 24, color: Colors.white)
                                      : Image.asset(
                                          color: const Color.fromARGB(255, 134, 132, 132),
                                          key: const ValueKey("1"),
                                          'assets/images/home_outlined.png',
                                          width: 22,
                                        ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Home',
                                  style: GoogleFonts.signika(fontSize: navChoice == 0 ? 16 : 13, color: navChoice == 0 ? Colors.white : const Color.fromARGB(255, 173, 170, 170)),
                                ),
                                const SizedBox(height: 5)
                              ],
                            ),
                          )),
                      InkWell(
                          onTap: () {
                            setState(() {
                              navChoice = 1;
                            });
                          },
                          child: SizedBox(
                            height: 75,
                            width: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: navChoice == 1
                                      ? Image.asset(key: const ValueKey("2"), 'assets/images/wallet.png', width: 24, color: Colors.white)
                                      : Image.asset(
                                          color: const Color.fromARGB(255, 134, 132, 132),
                                          key: const ValueKey("3"),
                                          'assets/images/wallet_outlined.png',
                                          width: 22,
                                        ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Wallet',
                                  style: GoogleFonts.signika(fontSize: navChoice == 1 ? 16 : 13, color: navChoice == 1 ? Colors.white : const Color.fromARGB(255, 134, 132, 132)),
                                ),
                                const SizedBox(height: 5)
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              //QR SCAN
              Positioned(
                  bottom: 25,
                  child: GestureDetector(
                      onTap: () {
                        Get.to(const QRViewScreen());
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            width: 60,
                            height: 60,
                            color: Colors.blue,
                            'assets/images/qr.png',
                          ),
                        ],
                      ))),
            ],
          ),
        ));
  }
}
 /*      */

   /*   , */