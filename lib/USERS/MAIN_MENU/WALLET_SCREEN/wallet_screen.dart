// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/USERS/MAIN_MENU/WALLET_SCREEN/add_money_screen.dart';
import 'package:final_project/USERS/MAIN_MENU/WALLET_SCREEN/balance_entrywidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart' as u;

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<u.User>(context);
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    final entryList = user.getEntries;
    return ListView(
      children: [
        SizedBox(
            width: dw,
            height: 500,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 32, bottom: 32),
                  width: 310,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: const LinearGradient(colors: [Color.fromARGB(255, 95, 3, 46), Color.fromARGB(255, 51, 3, 25)])),
                  child: Column(
                    children: [
                      Text(
                        'Balance',
                        style: GoogleFonts.signika(color: const Color.fromARGB(255, 167, 157, 157), fontSize: 16),
                      ),
                      Text(
                        "${user.balance.toStringAsFixed(2)} SAR",
                        style: GoogleFonts.signika(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 24.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Deposit History",
                        style: GoogleFonts.signika(color: const Color.fromARGB(255, 27, 27, 27), fontSize: 24),
                      ),
                      const Icon(
                        Icons.find_in_page_sharp,
                        color: Color.fromARGB(255, 18, 118, 199),
                        size: 34,
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 18, left: 28, right: 28),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color.fromARGB(255, 230, 208, 205)),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        color: Color.fromARGB(255, 185, 165, 162),
                        thickness: 1.25,
                      );
                    },
                    itemBuilder: (context, index) {
                      return AmountEntryWidget(entry: entryList[index]);
                    },
                    itemCount: entryList.length,
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                          backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 95, 3, 46)),
                          fixedSize: const MaterialStatePropertyAll(Size(285, 30))),
                      onPressed: () => Get.to(() => const AddMoneyScreen(), transition: Transition.leftToRightWithFade),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
                              text: '+',
                              children: [TextSpan(text: " Add Balance", style: GoogleFonts.signika(color: Colors.white, fontSize: 16))]))),
                ),
              ],
            )),
        const Divider(
          height: 1,
          color: Color.fromARGB(255, 211, 198, 198),
          thickness: 1.75,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Text('Points', style: GoogleFonts.signika(color: Colors.black, fontSize: 24)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 12),
                child: Image.asset(
                  alignment: Alignment.center,
                  'assets/images/points.png',
                  width: 128,
                  height: 128,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "${user.points}",
                  style: GoogleFonts.signika(
                    color: const Color.fromARGB(255, 95, 3, 46),
                    fontSize: 29,
                  ),
                ),
              ),
              Text(
                'Available Points',
                style: GoogleFonts.signika(
                  color: const Color.fromARGB(255, 95, 3, 46),
                  fontSize: 22.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "earn points by interacting with activites,\n      and replace them with goods in our shop!",
                  style: GoogleFonts.signika(
                    color: const Color.fromARGB(255, 109, 56, 81),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 60,
          color: Color.fromARGB(255, 211, 198, 198),
          thickness: 1.75,
        ),
        Column(
          children: [
            Text(
              'QR Code',
              style: GoogleFonts.signika(color: Colors.black, fontSize: 24),
            ),
            const SizedBox(height: 55),
            UnconstrainedBox(
                alignment: Alignment.center,
                child: Transform.scale(
                  scaleX: 1.4,
                  scaleY: 1.4,
                  child: Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 205, 205), border: Border.all(color: const Color.fromARGB(255, 230, 204, 204), width: 3), borderRadius: BorderRadius.circular(8)),
                      child: CachedNetworkImage(imageUrl: user.qrURL, width: 180, height: 180)),
                )),
            const SizedBox(height: 40),
            Text(
              "a QR Code, dedicated for your account,\n    let a manager scan you now for easier payments!",
              style: GoogleFonts.signika(color: const Color.fromARGB(255, 109, 56, 81), fontSize: 12),
            ),
            const SizedBox(height: 140)
          ],
        )
      ],
    );
  }
}
