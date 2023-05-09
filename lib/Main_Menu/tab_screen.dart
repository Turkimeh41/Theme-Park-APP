// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:final_project/Main_Menu/QR_SCREEN/qr_view.dart';
import 'package:final_project/Main_Menu/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int navChoice = 0;
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
        drawer: const Drawer(
          backgroundColor:  Color.fromARGB(255, 236, 220, 220),
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
          color: const Color.fromARGB(255, 236, 220, 220),
          height: dh,
          width: dw,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                  bottom: 0,
                  width: dw,
                  height: 120,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(colors: [Color.fromARGB(255, 109, 8, 55), Color.fromARGB(255, 138, 4, 73), Color.fromARGB(255, 87, 0, 41)]).createShader(bounds);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: dw,
                            height: 75,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -35,
                          child: Container(
                            width: 156,
                            height: 156,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )),
              Positioned(
                bottom: 0,
                width: dw,
                child: Padding(
                  padding: const EdgeInsets.only(left: 55, right: 55),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: navChoice == 0
                                      ? Image.asset(key: const ValueKey("0"), 'assets/images/home.png', width: 26, color: Colors.white)
                                      : Image.asset(
                                          key: const ValueKey("1"),
                                          'assets/images/home_outlined.png',
                                          width: 26,
                                        ),
                                ),
                                Text('Home', style: GoogleFonts.actor(color: const Color.fromARGB(255, 173, 170, 170), fontSize: 16)),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: navChoice == 1
                                      ? Image.asset(key: const ValueKey("0"), 'assets/images/wallet.png', width: 26, color: Colors.white)
                                      : Image.asset(
                                          key: const ValueKey("1"),
                                          'assets/images/wallet_outlined.png',
                                          width: 26,
                                        ),
                                ),
                                Text('Wallet', style: GoogleFonts.actor(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 10,
                  child: GestureDetector(
                      onTap: () {
                        Get.to(const QRViewScreen());
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/camera_v2.png',
                            width: 96,
                            height: 96,
                          ),
                          Text(
                            'Scan',
                            style: GoogleFonts.signika(color: Colors.white, fontSize: 18),
                          )
                        ],
                      ))),
            ],
          ),
        ));
  }
}
       /*        Provider.of<Activites>(context, listen: false).printActivites();
                Provider.of<Transactions>(context, listen: false).printTransactions();
                Provider.of<u.User>(context, listen: false).displayUser(); */








                /*           ElevatedButton(
              child: const Text('Camera QR'),
              onPressed: () async {
              
              }), */