import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/MANAGERS/DIALOG/anonymous_dialog.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_provider.dart';
import 'package:final_project/MANAGERS/Provider/anonymous_user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AnonymousWidget extends StatelessWidget {
  const AnonymousWidget({required this.anonymous, required this.type, super.key});
  final String type;
  final AnonymousUser anonymous;
  @override
  Widget build(BuildContext context) {
    final insAnonymous = Provider.of<AnonymousUsers>(context, listen: false);
    return InkWell(
      onTap: () {
        if (insAnonymous.userAnonymousLength == 4 && type == 'provider') {
          return;
        }
        AnonymousDialog.confirmDialog(insAnonymous, anonymous, context, type);
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
                style: GoogleFonts.signika(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
              )
            ],
          )),
    );
  }
}
