import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/manager_drawer.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/QR_VIEW/qrview_v1.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/dropdownbutton.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/popupmenu.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManagerMainMenu extends StatefulWidget {
  const ManagerMainMenu({super.key});

  @override
  State<ManagerMainMenu> createState() => _ManagerMainMenuState();
}

class _ManagerMainMenuState extends State<ManagerMainMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<Manager>(context);
    return Scaffold(
        drawer: const ManagerDrawer(),
        appBar: AppBar(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
          actions: const [PopUpMenu()],
          backgroundColor: const Color.fromARGB(255, 87, 0, 41),
        ),
        backgroundColor: const Color.fromARGB(255, 243, 235, 235),
        body: Stack(
          alignment: Alignment.center,
          children: [
            //DROP DOWN MENU
            const Positioned(top: 150, height: 200, width: 350, child: DropDownMenuButtonActivity()),
            Positioned(
                top: 10,
                left: 10,
                child: Text(
                  'Welcome ${manager.first_name} ${manager.last_name}',
                  style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: 35,
                left: 30,
                child: Text(
                  'We hope you had a great day',
                  style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 18),
                )),
            Positioned(
                top: 120,
                left: 25,
                child: Text(
                  'Start by selecting the activity you are managing,\n       then proceed to scan the QR Code of the user',
                  style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 12),
                )),
            //QR SCANNER
            Positioned(
                bottom: 25,
                child: GestureDetector(
                  onTap: () => Get.to(() => const QRViewScreen()),
                  child: Image.asset(
                    'assets/images/scanning.png',
                    width: 82,
                    height: 82,
                  ),
                )),
          ],
        ));
  }
}
