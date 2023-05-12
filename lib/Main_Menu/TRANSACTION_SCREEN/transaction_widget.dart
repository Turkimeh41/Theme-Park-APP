import 'package:final_project/Model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({required this.transaction, super.key});
  final Transaction transaction;
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        child: Container(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            height: 90,
            decoration: const BoxDecoration(color: Color.fromARGB(255, 230, 208, 205)),
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      transaction.actName,
                      style: GoogleFonts.signika(color: const Color.fromARGB(255, 32, 31, 31), fontSize: 18),
                    )),
                Positioned(top: 22, left: 5, child: Text((" ${transaction.actType}"), style: GoogleFonts.signika(color: const Color.fromARGB(255, 119, 109, 109), fontSize: 13))),
                Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction.transID,
                          style: GoogleFonts.signika(color: const Color.fromARGB(255, 119, 109, 109), fontSize: 12),
                        ),
                        Text(DateFormat("MMMM d, y, h:mm a").format(transaction.transaction_date), style: GoogleFonts.signika(color: const Color.fromARGB(255, 119, 109, 109), fontSize: 12)),
                      ],
                    )),
                Positioned(
                    bottom: 5,
                    right: 0,
                    child: Text(
                      "${transaction.actAmount} SAR",
                      style: GoogleFonts.signika(color: const Color.fromARGB(255, 95, 3, 46), fontSize: 16, fontWeight: FontWeight.bold),
                    ))
              ],
            )));
  }
}
