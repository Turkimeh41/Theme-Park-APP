import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Model/manager_transaction.dart';
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
            decoration: BoxDecoration(color: Colors.grey[400]),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                    top: 0,
                    left: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              width: 96,
                              imageUrl: transaction.actIMG,
                              fit: BoxFit.cover,
                            )),
                        const SizedBox(width: 5),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(("Transaction ID: ${transaction.id}"), style: GoogleFonts.signika(color: const Color.fromARGB(255, 119, 109, 109), fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(
                              'user ID: ${transaction.uID}',
                              style: GoogleFonts.signika(color: const Color.fromARGB(255, 119, 109, 109), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "act ID: ${transaction.actID}",
                              style: GoogleFonts.signika(color: const Color.fromARGB(255, 119, 109, 109), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(DateFormat("MMMM d, y, h:mm a").format(transaction.transaction_date), style: GoogleFonts.signika(color: const Color.fromARGB(255, 119, 109, 109), fontSize: 12)),
                          ],
                        )
                      ],
                    )),
                Positioned(
                    bottom: 5,
                    right: 0,
                    child: Text(
                      "${transaction.actAmount} SAR",
                      style: GoogleFonts.signika(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ))
              ],
            )));
  }
}
