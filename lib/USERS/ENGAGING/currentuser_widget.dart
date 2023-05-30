import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Model/current_user_model.dart';
import 'package:final_project/USERS/ENGAGING/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentUserWidget extends StatefulWidget {
  const CurrentUserWidget({super.key, required this.user});
  final CurrentUser user;
  @override
  State<CurrentUserWidget> createState() => _CurrentUserWidgetState();
}

class _CurrentUserWidgetState extends State<CurrentUserWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 1.25, offset: Offset(0, 0))],
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 211, 201, 201),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 15,
            child: Row(
              children: [
                widget.user.imgURL == null
                    ? const CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/placeholder.png'))
                    : CircleAvatar(radius: 28, backgroundImage: CachedNetworkImageProvider(widget.user.imgURL!)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: widget.user.first_name == null
                      ? [
                          Text("${widget.user.label}", style: GoogleFonts.signika(color: Colors.black, fontSize: 15)),
                          Text(
                            "@ANONY-${widget.user.id}",
                            style: GoogleFonts.signika(color: const Color.fromARGB(255, 19, 92, 151), fontSize: 8, fontWeight: FontWeight.bold),
                          )
                        ]
                      : [
                          Text("${widget.user.first_name} ${widget.user.last_name}", style: GoogleFonts.signika(color: Colors.black, fontSize: 15)),
                          Text(
                            "@${widget.user.username}",
                            style: GoogleFonts.signika(color: const Color.fromARGB(255, 19, 92, 151), fontSize: 10.5, fontWeight: FontWeight.bold),
                          )
                        ],
                )
              ],
            ),
          ),
          Positioned(
            top: -16,
            left: 40,
            child: widget.user.valueNotifier == null
                ? const SizedBox()
                : ValueListenableBuilder(
                    valueListenable: widget.user.valueNotifier!,
                    builder: (context, value, child) {
                      if (value == '') {
                        return const SizedBox();
                      } else {
                        return MessageBubble(message: value);
                      }
                    },
                  ),
          )
        ],
      ),
    );
  }
}
