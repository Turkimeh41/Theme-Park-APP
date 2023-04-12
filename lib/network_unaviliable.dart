import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'Handler/network_function.dart';

class NetworkUnaviliableScreen extends StatefulWidget {
  const NetworkUnaviliableScreen({super.key});

  @override
  State<NetworkUnaviliableScreen> createState() => _NetworkUnaviliableScreenState();
}

class _NetworkUnaviliableScreenState extends State<NetworkUnaviliableScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: dh,
        width: dw,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 65, 14, 38), Color.fromARGB(255, 78, 23, 51), Color.fromARGB(255, 63, 12, 38), Color.fromARGB(255, 36, 2, 18)])),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: dh * 0.15,
              child: Lottie.asset(
                'assets/animations/no-internet.json',
                width: dw * 0.55,
              ),
            ),
            Positioned(
                bottom: dh * 0.15,
                child: Column(
                  children: [
                    Text(
                      'Oops',
                      style: GoogleFonts.acme(fontSize: 36, color: Colors.white),
                    ),
                    SizedBox(
                      height: dh * 0.04,
                    ),
                    Text(
                      'Network Unavaliable',
                      style: GoogleFonts.acme(fontSize: 36, color: const Color.fromARGB(255, 167, 166, 166)),
                    ),
                    SizedBox(
                      height: dh * 0.1,
                    ),
                    StatefulBuilder(builder: (context, buildStateful) {
                      return loading == false
                          ? ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                                  backgroundColor: MaterialStatePropertyAll(Colors.amber[500]),
                                  fixedSize: const MaterialStatePropertyAll(Size(200, 60))),
                              onPressed: () async {
                                buildStateful(() {
                                  loading = true;
                                });
                                await Network.tryNetwork();
                                buildStateful(() {
                                  loading = false;
                                });
                              },
                              child: Text(
                                'Try again',
                                style: GoogleFonts.acme(fontSize: 28),
                              ))
                          : const CircularProgressIndicator();
                    }),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
