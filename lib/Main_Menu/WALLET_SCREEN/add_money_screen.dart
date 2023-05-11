// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:provider/provider.dart';
import 'package:final_project/Provider/user_provider.dart' as u;

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  late TextEditingController amountController;
  String? amountError;

  var amountFormatter = MaskTextInputFormatter(mask: '######', filter: {"#": RegExp(r'[\d.]+')}, type: MaskAutoCompletionType.lazy);
  @override
  void initState() {
    amountController = TextEditingController();
    super.initState();
  }

  bool validateAmount() {
    if (amountController.text.isEmpty) {
      setState(() {
        amountError = 'Invalid, Please specify a value in the field';
      });
      return false;
    }
    final amount = double.parse(amountController.text);
    if (amount <= 0) {
      setState(() {
        amountError = 'Invalid, bad amount';
      });
      return false;
    } else if (amount < 15) {
      setState(() {
        amountError = "Invalid, amount at least 15 SAR ";
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    //our instance of firestore
    final user = Provider.of<u.User>(context);
    return Scaffold(
        body: Container(
            color: const Color.fromARGB(255, 233, 223, 223),
            height: dh,
            width: dw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                    top: 15,
                    left: 15,
                    child: Transform.scale(
                      scaleX: -1,
                      child: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(
                            Icons.arrow_right_alt_rounded,
                            size: 46,
                            color: Color.fromARGB(255, 78, 14, 44),
                          )),
                    )),
                Positioned(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                                onChanged: (value) {
                                  if (amountError != null) {
                                    setState(() {
                                      amountError = null;
                                    });
                                  }
                                },
                                controller: amountController,
                                inputFormatters: [amountFormatter],
                                decoration: InputDecoration(
                                  errorText: amountError,
                                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 85, 9, 45), width: 2.5)),
                                  focusColor: const Color.fromARGB(255, 78, 14, 44),
                                )),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            ' SAR',
                            style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Minimum is 15 SAR',
                        style: GoogleFonts.signika(color: const Color.fromARGB(255, 85, 9, 45), fontSize: 15),
                      )
                    ],
                  ),
                ),
                Positioned(
                    bottom: 75,
                    child: NiceButtons(
                      progress: true,
                      borderColor: const Color.fromARGB(255, 39, 4, 20),
                      startColor: const Color.fromARGB(255, 124, 17, 67),
                      endColor: const Color.fromARGB(255, 85, 9, 45),
                      gradientOrientation: GradientOrientation.Horizontal,
                      stretch: false,
                      width: dw * 0.56,
                      height: dh * 0.06,
                      onTap: (finish) async {
                        bool validate = validateAmount();
                        log('amount validated with: $validate');
                        if (validate) {
                          try {
                            final amount = double.parse(amountController.text);
                            await user.rechargeBalance(amount);
                          } catch (e) {
                            setState(() {
                              log(e.toString());
                              finish();
                            });
                          }
                        }
                        await Future.delayed(const Duration(milliseconds: 200));
                        setState(() {
                          finish();
                        });
                      },
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.acme(color: Colors.white, fontSize: 27),
                      ),
                    )),
              ],
            )));
  }
}
