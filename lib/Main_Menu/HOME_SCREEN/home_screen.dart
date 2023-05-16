// ignore_for_file: unused_local_variable

import 'package:final_project/Main_Menu/HOME_SCREEN/activity_widget.dart';
import 'package:final_project/Provider/activites_provider.dart';
import 'package:final_project/Provider/participations_provider.dart';
import 'package:final_project/Provider/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:final_project/Provider/user_provider.dart' as u;

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
    controller = PageController(initialPage: 0, viewportFraction: 0.75);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    final user = Provider.of<u.User>(context, listen: true);
    final activity = Provider.of<Activites>(context, listen: true);
    final transaction = Provider.of<Transactions>(context, listen: true);
    final participation = Provider.of<Participations>(context, listen: true);
    final activityList = activity.activites;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Positioned(
                  top: 10,
                  left: 10,
                  child: RichText(
                    text: TextSpan(
                        text: 'Welcome\n',
                        style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 32),
                        children: [TextSpan(text: "    ${user.first_name} ${user.last_name}", style: GoogleFonts.signika(color: Colors.black, fontSize: 22))]),
                  )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            'Explore Activites',
            style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 28),
          ),
        ),
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
        )
      ],
    );
  }
}
