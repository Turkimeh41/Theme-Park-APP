import 'package:final_project/Model/activity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropDownItemActivity extends StatelessWidget {
  const DropDownItemActivity({required this.activity, super.key});
  final Activity activity;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(backgroundImage: NetworkImage(activity.img), radius: 32),
        const SizedBox(width: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.id,
              style: GoogleFonts.signika(color: Colors.grey[700], fontSize: 12),
            ),
            Text(
              activity.name,
              style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
        Text(
          '  ${activity.price} SAR',
          style: GoogleFonts.signika(color: const Color.fromARGB(255, 32, 143, 35), fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
