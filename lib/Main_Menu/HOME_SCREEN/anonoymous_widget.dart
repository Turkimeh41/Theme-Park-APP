import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Model/anonymous_user.dart';
import 'package:final_project/Provider/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnonymousWidget extends StatelessWidget {
  const AnonymousWidget({required this.anonymous, super.key});
  final AnonymousUser anonymous;
  @override
  Widget build(BuildContext context) {
    final insTransactions = Provider.of<Transactions>(context, listen: false);
    final array = insTransactions.getExpensesANDtransactionsByAnonymousID(anonymous.label);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: CachedNetworkImageProvider(anonymous.qrURL))),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anonymous.label,
              style: GoogleFonts.signika(fontSize: 12, color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat("MMMM d, y, h:mm").format(anonymous.assignedDate),
              style: GoogleFonts.signika(fontSize: 12, color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            )
          ],
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Procceed\nTransactions: ${array[1].toInt()}',
              style: GoogleFonts.signika(fontSize: 10, color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Total Expenses: ${array[0].toDouble().toStringAsFixed(2)}',
              style: GoogleFonts.signika(fontSize: 10, color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            )
          ],
        )
      ]),
    );
  }
}
