// ignore_for_file: use_build_context_synchronously

import 'package:final_project/Handler/general_handler.dart';
import 'package:final_project/Handler/user_firebase_handler.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class PageViewScreen extends StatefulWidget {
  const PageViewScreen({required this.customToken, super.key});
  final String customToken;
  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  late PageController pageController;
  ValueNotifier index = ValueNotifier<int>(0);
  @override
  void initState() {
    pageController = PageController(initialPage: 0, viewportFraction: 1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(alignment: Alignment.center, children: [
        PageView.builder(
          itemCount: 3,
          onPageChanged: (value) {
            index.value = value;
          },
          controller: pageController,
          itemBuilder: (context, index) {
            return index == 0
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                        ),
                      ),
                      GlassmorphicContainer(
                        width: dw * 0.8,
                        height: dh * 0.5,
                        borderRadius: 15,
                        linearGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                          const Color(0xFFffffff).withOpacity(0.1),
                          const Color(0xFFFFFFFF).withOpacity(0.05),
                        ], stops: const [
                          0.1,
                          1,
                        ]),
                        border: 2,
                        blur: 20,
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                          ],
                        ),
                      ),
                      Positioned(
                        top: dh * 0.3,
                        left: dw * 0.35,
                        child: SizedBox(
                            width: dw * 0.7,
                            child: Text(
                              'Payment',
                              style: GoogleFonts.acme(
                                shadows: [
                                  const Shadow(
                                    color: Colors.black,
                                  )
                                ],
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            )),
                      ),
                      Positioned(
                          left: dw * 0.18,
                          top: dh * 0.37,
                          child: Image.asset(
                            'assets/images/recharge.png',
                            width: dw * 0.6,
                          )),
                      Positioned(
                        top: dh * 0.63,
                        left: dw * 0.16,
                        child: SizedBox(
                            width: dw * 0.7,
                            child: Text(
                              'process payments without carrying money, recharge and your good to go!',
                              style: GoogleFonts.acme(fontSize: 18, color: Colors.white),
                            )),
                      )
                    ],
                  )
                : index == 1
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color.fromARGB(255, 65, 14, 38),
                                Color.fromARGB(255, 78, 23, 51),
                                Color.fromARGB(255, 63, 12, 38),
                                Color.fromARGB(255, 36, 2, 18),
                              ], begin: Alignment.topRight, end: Alignment.bottomLeft),
                            ),
                          ),
                          GlassmorphicContainer(
                            width: dw * 0.8,
                            height: dh * 0.5,
                            borderRadius: 15,
                            linearGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                              const Color(0xFFffffff).withOpacity(0.1),
                              const Color(0xFFFFFFFF).withOpacity(0.05),
                            ], stops: const [
                              0.1,
                              1,
                            ]),
                            border: 2,
                            blur: 20,
                            borderGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                              ],
                            ),
                          ),
                          Positioned(
                            top: dh * 0.3,
                            left: dw * 0.275,
                            child: SizedBox(
                                width: dw * 0.8,
                                child: Text(
                                  'Transactionless',
                                  style: GoogleFonts.acme(fontSize: 32, color: Colors.white),
                                )),
                          ),
                          Positioned(
                              left: dw * 0.15,
                              top: dh * 0.38,
                              child: Image.asset(
                                'assets/images/transactionless.png',
                                width: dw * 0.7,
                              )),
                          Positioned(
                              bottom: dh * 0.28,
                              child: SizedBox(
                                width: dw * 0.6,
                                child: Text(
                                  'With just a simple scan, you can easily make payments without exchanging anything else!',
                                  style: GoogleFonts.acme(color: Colors.white, fontSize: 18),
                                ),
                              ))
                        ],
                      )
                    : Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                            ),
                          ),
                          Positioned(
                            bottom: dh * 0.25,
                            left: dw * 0.04,
                            child: GlassmorphicContainer(
                              width: dw * 0.9,
                              height: dh * 0.5,
                              borderRadius: 15,
                              linearGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                                const Color(0xFFffffff).withOpacity(0.1),
                                const Color(0xFFFFFFFF).withOpacity(0.05),
                              ], stops: const [
                                0.1,
                                1,
                              ]),
                              border: 2,
                              blur: 20,
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                                  const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: dh * 0.67,
                              left: dw * 0.185,
                              child: Text(
                                'And much more!',
                                style: GoogleFonts.acme(color: Colors.white, fontSize: 36),
                              )),
                          Positioned(
                              bottom: dh * 0.365,
                              left: dw * 0.105,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: dw,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          color: Color.fromARGB(255, 245, 228, 172),
                                          size: 10,
                                        ),
                                        SizedBox(
                                          width: dw * 0.03,
                                        ),
                                        Text(
                                          'Customize Your Profile!',
                                          style: GoogleFonts.acme(color: Colors.white, fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: dh * 0.015,
                                  ),
                                  SizedBox(
                                    width: dw,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          color: Color.fromARGB(255, 245, 228, 172),
                                          size: 10,
                                        ),
                                        SizedBox(
                                          width: dw * 0.03,
                                        ),
                                        Text(
                                          'Earn Points for Associating with activites\n and consume it to earn goods!',
                                          style: GoogleFonts.acme(color: Colors.white, fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: dh * 0.015,
                                  ),
                                  SizedBox(
                                    width: dw,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          color: Color.fromARGB(255, 245, 228, 172),
                                          size: 10,
                                        ),
                                        SizedBox(
                                          width: dw * 0.03,
                                        ),
                                        Text(
                                          'Track/keep up to date to all your transactions!',
                                          style: GoogleFonts.acme(color: Colors.white, fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: dh * 0.015,
                                  ),
                                  SizedBox(
                                    width: dw,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          color: Color.fromARGB(255, 245, 228, 172),
                                          size: 10,
                                        ),
                                        SizedBox(
                                          width: dw * 0.03,
                                        ),
                                        SizedBox(
                                          child: Text(
                                            'View available activites and their details\n in the park',
                                            style: GoogleFonts.acme(color: Colors.white, fontSize: 16),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: dh * 0.015,
                                  ),
                                  SizedBox(
                                    width: dw,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          color: Color.fromARGB(255, 245, 228, 172),
                                          size: 10,
                                        ),
                                        SizedBox(
                                          width: dw * 0.03,
                                        ),
                                        SizedBox(
                                          child: Text(
                                            'Share your account with family members\n to make payments even more cashless!',
                                            style: GoogleFonts.acme(color: Colors.white, fontSize: 16),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      );
          },
        ),
        Positioned(
            top: dh * 0.05,
            child: Text(
              'Welcome to',
              style: GoogleFonts.acme(color: Colors.white, fontSize: 42),
            )),
        Positioned(
            top: dh * 0.12,
            child: Row(
              children: [
                Text(
                  'Swipe And Pay',
                  style: GoogleFonts.acme(color: Colors.white, fontSize: 36),
                )
              ],
            )),
        Positioned(
            bottom: dh * 0.05,
            left: 0.1 * dw,
            child: NiceButtons(
              borderColor: Colors.amber[900]!,
              startColor: Colors.amber,
              endColor: Colors.amber[800]!,
              borderRadius: 15,
              stretch: false,
              onTap: (_) async {
                final pref = await SharedPreferences.getInstance();
                pref.setBool('intro-done', true);
                log('intro-done: ${true}');
                Navigator.of(context).popUntil((route) => route.isFirst);
                await GeneralHandler.signInWithCustomToken(widget.customToken);

                await UserFirebaseHandler.setLastLogin();
              },
              width: dw * 0.8,
              height: dh * 0.05,
              child: Text('Done', style: GoogleFonts.acme(fontSize: 28, color: Colors.white)),
            )),
        //VALUE LISTENABLE BUILDER, this widget listens to a value, and then will rebuilt whenever that value changes, USEFUL :D
        Positioned(
          bottom: dh * 0.17,
          left: dw * 0.36,
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 60,
                child: ValueListenableBuilder(
                    valueListenable: index,
                    builder: (context, index, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: index == 0
                            ? const Icon(
                                Icons.horizontal_rule_rounded,
                                color: Colors.white,
                                size: 38,
                                key: ValueKey('1'),
                              )
                            : const Icon(
                                Icons.circle,
                                color: Colors.black,
                                size: 16,
                                key: ValueKey('2'),
                              ),
                      );
                    }),
              ),
              SizedBox(
                width: 35,
                height: 60,
                child: ValueListenableBuilder(
                    valueListenable: index,
                    builder: (context, index, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: index == 1
                            ? const Icon(
                                Icons.horizontal_rule_rounded,
                                color: Colors.white,
                                size: 38,
                                key: ValueKey('3'),
                              )
                            : const Icon(
                                Icons.circle,
                                color: Colors.black,
                                size: 16,
                                key: ValueKey('4'),
                              ),
                      );
                    }),
              ),
              SizedBox(
                width: 35,
                height: 60,
                child: ValueListenableBuilder(
                    valueListenable: index,
                    builder: (context, index, child) {
                      return SizedBox(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: index == 2
                              ? const Icon(
                                  Icons.horizontal_rule_rounded,
                                  color: Colors.white,
                                  size: 38,
                                  key: ValueKey('5'),
                                )
                              : const Icon(
                                  Icons.circle,
                                  color: Colors.black,
                                  size: 16,
                                  key: ValueKey('6'),
                                ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
