import 'package:final_project/USERS/MAIN_MENU/DRAWER/STATISTICS_SCREEN/bar_chart_played.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: GoogleFonts.signika(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ListView(
          padding: const EdgeInsets.only(
            top: 24,
            left: 12,
            right: 12,
          ),
          children: [
            RichText(
                text: TextSpan(
              text: 'Statistics',
              style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: '\n      Here you can monitor/check\n        all your personal statistics easily!', style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 13))
              ],
            )),
            const SizedBox(height: 40),
            Text('Most Played Activites', style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const SizedBox(height: 280, child: BarChartPlayed()),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 0), child: Divider(thickness: 1.25)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
