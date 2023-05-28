// ignore_for_file: use_build_context_synchronously
import 'package:final_project/Handler/manager_firebase_handler.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnonymousDialog {
  static Future<void> confirmDialog(AnonymousUsers insAnonymous, AnonymousUser anony, BuildContext context, String type) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          TextEditingController labelController = TextEditingController();
          TextEditingController balanceController = TextEditingController();
          FocusNode labelFocus = FocusNode();
          FocusNode balanceFocus = FocusNode();

          return StatefulBuilder(builder: (context, setStateful) {
            balanceFocus.addListener(() {
              setStateful(() {});
            });
            labelFocus.addListener(() {
              setStateful(() {});
            });
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: SizedBox(
                  width: 300,
                  height: 280,
                  child: Column(children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: const EdgeInsets.only(left: 30),
                            alignment: Alignment.centerLeft,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Confirm', style: GoogleFonts.acme(color: Colors.white, fontSize: 24)),
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.white,
                                  ))
                            ]))),
                    Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 40,
                                width: 180,
                                child: TextField(
                                    controller: labelController,
                                    focusNode: labelFocus,
                                    style: GoogleFonts.signika(fontSize: 18),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        size: labelFocus.hasFocus ? 28 : 22,
                                        Icons.supervised_user_circle,
                                        color: labelFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                      ),
                                      filled: true,
                                      fillColor: const Color.fromARGB(255, 224, 224, 224),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 0.8)),
                                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 0.8)),
                                      errorStyle: GoogleFonts.signika(fontSize: 11.5),
                                      labelText: 'Label',
                                      labelStyle: GoogleFonts.acme(
                                          fontSize: labelFocus.hasFocus ? 22 : 18, color: labelFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                                    )),
                              ),
                              type == 'normal'
                                  ? SizedBox(
                                      height: 40,
                                      width: 180,
                                      child: TextField(
                                          controller: balanceController,
                                          focusNode: balanceFocus,
                                          style: GoogleFonts.signika(fontSize: 18),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            prefixIcon: Icon(
                                              size: balanceFocus.hasFocus ? 28 : 22,
                                              Icons.attach_money,
                                              color: balanceFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100),
                                            ),
                                            filled: true,
                                            fillColor: const Color.fromARGB(255, 224, 224, 224),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 0.8)),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 0.8)),
                                            errorStyle: GoogleFonts.signika(fontSize: 11.5),
                                            labelText: 'Balance',
                                            labelStyle: GoogleFonts.acme(
                                                fontSize: balanceFocus.hasFocus ? 22 : 18,
                                                color: balanceFocus.hasFocus ? const Color.fromARGB(255, 110, 30, 63) : const Color.fromARGB(255, 102, 100, 100)),
                                          )),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                        child: UnconstrainedBox(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 228, 175, 15)),
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  fixedSize: const MaterialStatePropertyAll(Size(190, 30))),
                              onPressed: () async {
                                await ManagerFirebaseHandler.assignAnonyQRCODE(insAnonymous, anony, labelController.text, type, type == 'provider' ? null : double.parse(balanceController.text));
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Confirm and Print',
                                style: GoogleFonts.acme(fontSize: 21),
                              )),
                        ),
                      ),
                    )
                  ])),
            );
          });
        });
  }
}
