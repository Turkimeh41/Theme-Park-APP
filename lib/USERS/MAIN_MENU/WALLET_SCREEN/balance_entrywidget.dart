import 'package:flutter/material.dart';
import 'package:final_project/Model/balance_entry.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AmountEntryWidget extends StatelessWidget {
  const AmountEntryWidget({required this.entry, super.key});
  final AmountEntry entry;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            child: Text(
              entry.id,
              style: GoogleFonts.signika(color: const Color.fromARGB(255, 37, 36, 36), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: [
              Text(
                "+${entry.amount} SAR",
                style: GoogleFonts.signika(color: const Color.fromARGB(255, 26, 122, 28), fontSize: 16),
              ),
              Text(
                DateFormat("MMMM d, y, h:mm a").format(entry.date),
                style: GoogleFonts.signika(color: const Color.fromARGB(255, 37, 36, 36)),
              )
            ],
          )
        ],
      ),
    );
  }
}
