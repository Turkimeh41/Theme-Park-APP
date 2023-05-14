import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Main_Menu/ACCOUNT_SCREEN/account_screen.dart';
import 'package:final_project/Main_Menu/TRANSACTION_SCREEN/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Provider/user_provider.dart' as u;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<u.User>(context, listen: true);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
          width: 180,
          height: 168,
          decoration: const BoxDecoration(color: Color.fromARGB(255, 102, 5, 50), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              user.userImg_link.length < 7
                  ? const CircleAvatar(radius: 36, backgroundImage: AssetImage('assets/images/placeholder.png'))
                  : CircleAvatar(
                      radius: 36,
                      backgroundImage: CachedNetworkImageProvider(user.userImg_link),
                    ),
              Text(
                "${user.first_name} ${user.last_name}",
                style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
              ),
              Text(
                '@${user.username}',
                style: GoogleFonts.signika(color: Colors.blue[600], fontWeight: FontWeight.bold, fontSize: 12),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.to(() => const AccountScreen(), transition: Transition.leftToRight),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 10),
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
        const Divider(
          height: 1,
          color: Color.fromARGB(255, 211, 198, 198),
          thickness: 1.25,
        ),
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.stacked_bar_chart,
                  size: 32,
                  color: Colors.black,
                ),
                const SizedBox(width: 18),
                Text('Statistics', style: GoogleFonts.signika(color: Colors.black, fontSize: 15))
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          color: Color.fromARGB(255, 211, 198, 198),
          thickness: 1.25,
        ),
        InkWell(
          onTap: () => Get.to(() => const TransactionScreen(), transition: Transition.leftToRight),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 10),
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
        const Divider(
          height: 1,
          color: Color.fromARGB(255, 211, 198, 198),
          thickness: 1.25,
        ),
      ],
    );
  }
}
