import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PopUpMenu extends StatelessWidget {
  const PopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: Colors.white,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
              child: InkWell(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      Text(
                        'Logout',
                        style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
                      ),
                      const SizedBox(width: 5),
                    ],
                  )))
        ];
      },
    );
  }
}
