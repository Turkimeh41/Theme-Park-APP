// ignore_for_file: unused_local_variable

import 'package:final_project/USERS/MAIN_MENU/HOME_SCREEN/activity_widget.dart';
import 'package:final_project/USERS/MAIN_MENU/HOME_SCREEN/anonoymous_widget.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart' as u;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController controller;
  int currentIndex = 0;

  @override
  void initState() {
    controller = PageController(initialPage: 0, viewportFraction: 0.76);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    final user = Provider.of<u.User>(context, listen: true);
    final activity = Provider.of<Activites>(context, listen: true);
    final participation = Provider.of<Participations>(context, listen: true);
    final activityList = activity.activites;
    final anonymousUsersList = user.getAnonymousUsers;
    return ListView(
      children: [
        SizedBox(
          height: 140,
          child: Stack(
            children: [
              Positioned(
                  top: 15,
                  left: 30,
                  child: RichText(
                    text: TextSpan(text: 'Welcome', style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 20), children: [
                      TextSpan(text: " ${user.first_name} ${user.last_name}\n", style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                      TextSpan(text: '      We hope you had a great day!', style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 18))
                    ]),
                  )),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 10),
            child: RichText(
              text: TextSpan(text: 'Explore Activites\n', style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 23, fontWeight: FontWeight.bold), children: [
                TextSpan(
                    text: "     explore all activites inside \n          the theme park, and get to know all activites!",
                    style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 12))
              ]),
            )),
        SizedBox(
          width: dw,
          height: 200,
          child: PageView.custom(
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            controller: controller,
            childrenDelegate: SliverChildBuilderDelegate((context, index) {
              double scale = index == currentIndex ? 1 : 0.75;
              return TweenAnimationBuilder<double>(
                  tween: Tween(begin: scale, end: scale),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: ActivityWidget(activity: activityList[index]));
            }, childCount: activityList.length),
            scrollDirection: Axis.horizontal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, top: 96, bottom: 10),
          child: RichText(
            text: TextSpan(text: 'Anonymous Users\n', style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 23, fontWeight: FontWeight.bold), children: [
              TextSpan(
                  text:
                      "  connect QR codes bracelets of family members/friends \n    with your account balance to make it much easier\n    for them to do payments\n    find a manager in the park to get started!",
                  style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 12))
            ]),
          ),
        ),
        UnconstrainedBox(
          child: Container(
            height: 220,
            width: 290,
            decoration: BoxDecoration(color: const Color.fromARGB(255, 230, 208, 205), borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return AnonymousWidget(anonymous: anonymousUsersList[index]);
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    color: Color.fromARGB(255, 165, 138, 134),
                    thickness: 1.25,
                  );
                },
                itemCount: anonymousUsersList.length),
          ),
        ),
        const SizedBox(height: 50)
      ],
    );
  }
}
