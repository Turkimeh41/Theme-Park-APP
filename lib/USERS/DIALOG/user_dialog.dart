import 'package:final_project/USERS/MAIN_MENU/WALLET_SCREEN/add_money_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDialog {
  static Future<void> balanceDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Theme.of(context).primaryColor,
            child: SizedBox(
                width: 280,
                height: 200,
                child: Column(children: [
                  SizedBox(
                      width: 280,
                      height: 50,
                      child: Text(
                        'Insufficent-balance',
                        style: GoogleFonts.acme(color: Colors.white, fontSize: 18),
                      )),
                  SizedBox(
                      height: 100, width: 280, child: Text('Your balance is not sufficent, would you like to recharge your balance now?', style: GoogleFonts.acme(color: Colors.white, fontSize: 19))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              fixedSize: const MaterialStatePropertyAll(Size(120, 30)),
                              backgroundColor: const MaterialStatePropertyAll(Colors.amber)),
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: Text('Cancel', style: GoogleFonts.acme(color: Colors.white, fontSize: 16))),
                      ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              fixedSize: const MaterialStatePropertyAll(Size(120, 30)),
                              backgroundColor: const MaterialStatePropertyAll(Colors.amber)),
                          onPressed: () {
                            Get.to(() => const AddBalanceScreen());
                          },
                          child: Text('Recharge', style: GoogleFonts.acme(color: Colors.white, fontSize: 16))),
                    ],
                  )
                ])),
          );
        });
  }
}
