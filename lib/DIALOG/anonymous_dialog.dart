// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:final_project/Handler/manager_firebase_handler.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnonymousDialog {
  static Future<void> confirmDialog(AnonymousUsers insAnonymous, AnonymousUser anony, BuildContext context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        bool loading = false;
        TextEditingController labelController = TextEditingController();
        return StatefulBuilder(builder: (context, setStateful) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[900]),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 12),
                    child: SizedBox(
                      width: 250,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Confirm',
                            style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
                          ),
                          IconButton(
                              onPressed: loading == false
                                  ? () {
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              icon: const Icon(Icons.cancel))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        width: 300,
                        color: Colors.grey[600],
                        child: SizedBox(
                          width: 200,
                          height: 50,
                          child: TextField(
                            keyboardType: TextInputType.text,
                            style: GoogleFonts.signika(color: Colors.white),
                            controller: labelController,
                            decoration: InputDecoration(
                                labelStyle: GoogleFonts.signika(color: const Color.fromARGB(255, 201, 196, 196), fontSize: 18),
                                labelText: 'label',
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 50,
                    width: 250,
                    child: Align(
                      alignment: Alignment.center,
                      child: loading == false
                          ? ElevatedButton(
                              onPressed: () async {
                                setStateful(() {
                                  loading = true;
                                });
                                await ManagerFirebaseHandler.assignAnonyQRCODEtoProviderID(insAnonymous, anony, labelController.text);
                                setStateful(() {
                                  loading = false;
                                });
                                try {
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  log(e.toString());
                                }
                              },
                              style: ButtonStyle(
                                fixedSize: const MaterialStatePropertyAll(Size(220, 30)),
                                backgroundColor: const MaterialStatePropertyAll(Colors.black),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              ),
                              child: Text(
                                'Print and Confirm',
                                style: GoogleFonts.signika(color: Colors.white, fontSize: 18),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(right: 30.0),
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
