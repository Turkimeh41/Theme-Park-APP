import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/USERS/ENGAGING/currentuser_widget.dart';
import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:final_project/USERS/ENGAGING/engage_handler.dart';
import 'package:final_project/USERS/Provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EngagingScreen extends StatefulWidget {
  const EngagingScreen({super.key});

  @override
  State<EngagingScreen> createState() => _EngagingScreenState();
}

class _EngagingScreenState extends State<EngagingScreen> {
  late EngageHandler handler;
  late ValueNotifier notifier;
  @override
  void initState() {
    handler = EngageHandler(Provider.of<User>(context, listen: false), Provider.of<ActivityEngagement>(context, listen: false));
    notifier = ValueNotifier(Provider.of<ActivityEngagement>(context, listen: false).currentActivity!.duration);
    handler.setState = setState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final insEngagement = Provider.of<ActivityEngagement>(context);
    final currentUsersList = insEngagement.currentusers;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromARGB(255, 252, 242, 242),
        body: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                ),
                child: Column(
                  children: [
                    Container(
                        width: 240,
                        height: 150,
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(fit: BoxFit.cover, image: CachedNetworkImageProvider(insEngagement.currentActivity!.img)))),
                    Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Text(insEngagement.currentActivity!.name, style: GoogleFonts.signika(color: const Color.fromARGB(255, 87, 0, 41), fontSize: 24, fontWeight: FontWeight.bold))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${insEngagement.currentusers.length}/${insEngagement.currentActivity!.seats} Users Currently",
                            style: GoogleFonts.signika(color: const Color.fromARGB(255, 87, 0, 41), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'duration: ${insEngagement.currentActivity!.duration} min',
                            style: GoogleFonts.signika(color: const Color.fromARGB(255, 87, 0, 41), fontSize: 13, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 18),
                    itemCount: currentUsersList.length,
                    itemBuilder: (context, index) => CurrentUserWidget(user: currentUsersList[index])),
              ),
              Container(
                  decoration: const BoxDecoration(color: Color.fromARGB(255, 87, 0, 41), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                  width: dw,
                  height: 75,
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 32, top: 16, bottom: 16, right: 8),
                        child: TextField(
                            focusNode: handler.messageFocus,
                            controller: handler.messageController,
                            style: GoogleFonts.signika(color: Colors.black, fontSize: 18),
                            decoration: InputDecoration(
                                hintText: 'Send something for others to see!',
                                hintStyle: GoogleFonts.signika(color: Colors.grey[600], fontSize: 16),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
                      )),
                      IconButton(onPressed: () => handler.sendMessage(), icon: const Icon(Icons.send, color: Colors.white))
                    ],
                  ))
            ],
          ),
        ));
  }
}
