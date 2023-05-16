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
              style: GoogleFonts.signika(color: const Color.fromARGB(255, 71, 68, 68), fontSize: 13),
            ),
          ),
          Column(
            children: [
              Text(
                "+${entry.amount}",
                style: GoogleFonts.signika(color: const Color.fromARGB(255, 68, 151, 70), fontSize: 16),
              ),
              Text(
                DateFormat("MMMM d, y, h:mm a").format(entry.date),
                style: GoogleFonts.signika(color: const Color.fromARGB(255, 71, 68, 68)),
              )
            ],
          )
        ],
      ),
    );
  }
}
