

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Model/activity.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({required this.activity, super.key});
  final Activity activity;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                      activity.img,
                    ))),
          ),
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.6)),
          )),
          Positioned(
              top: 10,
              left: 10,
              child: Text(
                activity.name,
                style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
              ))
        ],
      ),
    );
  }
}
