// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:final_project/Handler/utils_handler.dart';
import 'package:final_project/Main_Menu/HOME_SCREEN/home_screen.dart';
import 'package:final_project/Main_Menu/QR_SCREEN/qr_view.dart';
import 'package:final_project/Main_Menu/QR_SCREEN/qr_view_v2.dart';
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

class _TabScreenState extends State<TabScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offsetAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.03), end: const Offset(0, 0)).animate(controller);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1).animate(controller);
    controller.animateTo(1.0);

    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String wallet = 'Wallet';
  String home = 'Home';
  int navChoice = 0;
  bool loading = false;
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
          centerTitle: true,
          title: Text(
            navChoice == 0 ? home : wallet,
            style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
          ),
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
                                Text('Logout', style: GoogleFonts.acme(color: Colors.white, fontSize: 16)),
                              ],
                            )),
                      ];
                    },
                  )),
            )
          ],
        ),
        body: RefreshIndicator(
          color: Colors.amber,
          onRefresh: () async {
            setState(() {
              loading = true;
            });
            await UtilityHandler.refresh(context);
            setState(() {
              loading = false;
            });
          },
          child: loading == false
              ? Container(
                  color: const Color.fromARGB(255, 243, 235, 235),
                  height: dh,
                  width: dw,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // NAVIGATION TO THE OTHER SCREENS
                      if (navChoice == 0)
                        Container(
                            padding: const EdgeInsets.only(bottom: 60), child: SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: fadeAnimation, child: const HomeScreen())))
                      else if (navChoice == 1)
                        Container(
                            padding: const EdgeInsets.only(bottom: 60), child: SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: fadeAnimation, child: const WalletScreen()))),

                      //CONTAINER THAT DOES THE SHADERMASK
                      Positioned(
                          bottom: 0,
                          width: dw,
                          height: 100,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(colors: [
                                Color.fromARGB(255, 87, 0, 41),
                                Color.fromARGB(255, 71, 1, 34),
                                Color.fromARGB(255, 48, 4, 25),
                                Color.fromARGB(255, 71, 1, 34),
                                Color.fromARGB(255, 87, 0, 41)
                              ]).createShader(bounds);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  right: dw * 0.32,
                                  bottom: dh * 0.04,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: dw,
                                    height: 55,
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (navChoice != 0) {
                                        controller.reset();
                                        navChoice = 0;
                                        controller.forward();
                                      }
                                    });
                                  },
                                  child: SizedBox(
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
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: Text(
                                            'Home',
                                            style: GoogleFonts.signika(fontSize: navChoice == 0 ? 16 : 13, color: navChoice == 0 ? Colors.white : const Color.fromARGB(255, 173, 170, 170)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (navChoice != 1) {
                                        controller.reset();
                                        navChoice = 1;
                                        controller.forward();
                                      }
                                    });
                                  },
                                  child: SizedBox(
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
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: Text(
                                            'Wallet',
                                            style: GoogleFonts.signika(fontSize: navChoice == 1 ? 16 : 13, color: navChoice == 1 ? Colors.white : const Color.fromARGB(255, 134, 132, 132)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),

                      //QR SCAN
                      Positioned(
                          bottom: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(const QRViewScreen(), transition: Transition.upToDown);
                              },
                              child: Image.asset(
                                width: 76,
                                height: 76,
                                'assets/images/scanning.png',
                              ))),
                    ],
                  ),
                )
              : Container(
                  height: dh,
                  width: dw,
                  color: const Color.fromARGB(255, 243, 235, 235),
                ),
        ));
  }
}
