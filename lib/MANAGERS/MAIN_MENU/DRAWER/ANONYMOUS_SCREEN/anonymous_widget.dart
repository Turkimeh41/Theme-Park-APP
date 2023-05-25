import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/DIALOG/anonymous_dialog.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AnonymousWidget extends StatelessWidget {
  const AnonymousWidget({required this.anonymous, super.key});
  final AnonymousUser anonymous;
  @override
  Widget build(BuildContext context) {
    final insAnonymous = Provider.of<AnonymousUsers>(context, listen: false);
    log(anonymous.qrURL);
    return InkWell(
      onTap: () {
        if (insAnonymous.userAnonymousLength == 3) {
          return;
        }
        AnonymousDialog.confirmDialog(insAnonymous, anonymous, context);
      },
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: CachedNetworkImageProvider(anonymous.qrURL))),
              ),
              Text(
                anonymous.id,
                style: GoogleFonts.signika(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.bold),
              )
            ],
          )),
    );
  }
}
