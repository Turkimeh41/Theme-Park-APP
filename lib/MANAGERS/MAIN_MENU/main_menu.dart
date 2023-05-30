// ignore_for_file: prefer_const_constructors

import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/manager_drawer.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/QR_VIEW/qrview_v1.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/dropdownbutton.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/popupmenu.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/USERS/ENGAGING/currentuser_widget.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
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
    final insActivities = Provider.of<Activites>(context);
    final currentUsersList = insActivities.currentUsers;
    return Scaffold(
        drawer: const ManagerDrawer(),
        appBar: AppBar(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
          actions: const [PopUpMenu()],
          backgroundColor: const Color.fromARGB(255, 87, 0, 41),
        ),
        backgroundColor: const Color.fromARGB(255, 243, 235, 235),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
                  top: 60,
                  left: 25,
                  child: Text(
                    'Start by selecting the activity you are managing,\n       then proceed to scan the QR Code of the user',
                    style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 12),
                  )),
              //DROP DOWN MENU
              Positioned(top: 80, height: 200, width: 350, child: DropDownMenuButtonActivity()),
              Positioned(
                top: 200,
                child: insActivities.loadingCurrentUsers == false
                    ? Column(
                        children: [
                          Text(
                            '${insActivities.currentUsers.length}/${insActivities.selectedActivity.seats} of seats availiable',
                            style: GoogleFonts.signika(color: const Color.fromARGB(255, 87, 0, 41), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            height: 250,
                            width: 320,
                            child: ListView.separated(
                                padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                                separatorBuilder: (context, index) => SizedBox(height: 10),
                                itemCount: currentUsersList.length,
                                itemBuilder: (context, index) => CurrentUserWidget(user: currentUsersList[index])),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                              style: ButtonStyle(fixedSize: MaterialStatePropertyAll(Size(220, 30)), backgroundColor: MaterialStatePropertyAll(const Color.fromARGB(255, 87, 0, 41))),
                              onPressed: insActivities.selectedActivity.started == false ? () async => insActivities.startActivity() : () async => insActivities.endActivity(),
                              child: Text(insActivities.selectedActivity.started == false ? 'Start Activity!' : 'End Activity', style: GoogleFonts.signika(color: Colors.white, fontSize: 19)))
                        ],
                      )
                    : CircularProgressIndicator(),
              ),

              //QR SCANNER
              Positioned(
                  bottom: 5,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const QRViewScreen()),
                    child: Image.asset(
                      'assets/images/scanning.png',
                      width: 82,
                      height: 82,
                    ),
                  )),
            ],
          ),
        ));
  }
}
