import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/ACCOUNT_SCREEN/account_screen.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/ANONYMOUS_SCREEN/anonymous_screen.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/TRANSACTION_SCREEN/transaction_screen.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManagerDrawer extends StatelessWidget {
  const ManagerDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<Manager>(context, listen: true);
    return Drawer(
      width: 300,
      backgroundColor: const Color.fromARGB(255, 230, 216, 216),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color.fromARGB(255, 87, 0, 41), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
            padding: const EdgeInsets.only(top: 32, left: 4, right: 4, bottom: 12),
            margin: const EdgeInsets.only(bottom: 18),
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                manager.imgURL == null
                    ? const CircleAvatar(radius: 36, backgroundImage: AssetImage('assets/images/placeholder.png'))
                    : CircleAvatar(
                        radius: 36,
                        backgroundImage: CachedNetworkImageProvider(manager.imgURL!),
                      ),
                Text(
                  "${manager.first_name} ${manager.last_name}",
                  style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
                ),
                Text(
                  '@${manager.username}',
                  style: GoogleFonts.signika(color: Colors.blue[600], fontWeight: FontWeight.bold, fontSize: 12),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Personal',
                style: GoogleFonts.signika(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () => Get.to(() => const AccountScreen(), transition: Transition.leftToRight),
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 18),
                  Text('Account', style: GoogleFonts.signika(color: Colors.black, fontSize: 15))
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () => Get.to(() => const TransactionScreen(), transition: Transition.leftToRight),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/transaction.png',
                    width: 32,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 18),
                  Text('Transactions', style: GoogleFonts.signika(color: Colors.black, fontSize: 15))
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(
            thickness: 1.5,
            height: 1,
            color: Color.fromARGB(255, 207, 186, 186),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 20),
              child: Text(
                'Manage',
                style: GoogleFonts.signika(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () => Get.to(() => const AnonymousScreen(), transition: Transition.leftToRight),
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/spyware.png',
                    width: 32,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 18),
                  Text('Anonymous Users', style: GoogleFonts.signika(color: Colors.black, fontSize: 15))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
