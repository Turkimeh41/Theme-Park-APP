import 'package:final_project/utility_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PopUpMenu extends StatelessWidget {
  const PopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final insUtility = Provider.of<Utility>(context);
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Colors.white),
        popupMenuTheme: const PopupMenuThemeData(color: Color.fromARGB(255, 102, 5, 50)),
        dividerTheme: const DividerThemeData(color: Colors.white),
      ),
      child: PopupMenuButton(
        color: Colors.white,
        itemBuilder: (context) {
          return [
            PopupMenuItem(
                child: InkWell(
                    onTap: () async => insUtility.managerLogout(),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.black),
                        Text('Logout', style: GoogleFonts.signika(color: Colors.black, fontSize: 16)),
                        const SizedBox(width: 5),
                      ],
                    )))
          ];
        },
      ),
    );
  }
}
