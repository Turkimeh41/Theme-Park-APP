import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Model/activity.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({required this.activity, super.key});
  final Activity activity;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(activity.id);
      },
      child: Hero(
        tag: activity.id,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    activity.img,
                  ))),
        ),
      ),
    );
  }
}
