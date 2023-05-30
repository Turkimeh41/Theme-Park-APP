import 'package:final_project/USERS/MAIN_MENU/DRAWER/STATISTICS_SCREEN/activity_maxplayed.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BarChartPlayed extends StatefulWidget {
  const BarChartPlayed({super.key});

  @override
  State<BarChartPlayed> createState() => _BarChartPlayedState();
}

class _BarChartPlayedState extends State<BarChartPlayed> {
  late List<ActivityPlayed> barData;

  @override
  Widget build(BuildContext context) {
    int counter = 0;
    final insParticipations = Provider.of<Participations>(context, listen: true);
    double maxPlayed = insParticipations.getMaxPlayedActivityDivisbleBy10();
    final insActivites = Provider.of<Activites>(context, listen: true);
    barData = insParticipations.getMax6Activites(insActivites);
    return BarChart(BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false, border: Border.all(width: 0.5)),
        titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                    space: 0,
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}',
                      style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 20),
                    ));
              },
            )),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
              reservedSize: 30,
              showTitles: true,
              getTitlesWidget: (value, meta) => getTiles(value, meta),
            ))),
        maxY: maxPlayed,
        barGroups: barData.map((bar) {
          return BarChartGroupData(x: 0 + counter++, barRods: [
            BarChartRodData(
                gradient: const LinearGradient(colors: [Color.fromARGB(255, 48, 0, 22), Color.fromARGB(255, 121, 11, 61)]),
                backDrawRodData: BackgroundBarChartRodData(toY: maxPlayed, show: true, color: const Color.fromARGB(255, 204, 195, 195)),
                width: 15,
                borderRadius: BorderRadius.circular(2),
                color: Theme.of(context).primaryColor,
                toY: bar.played.toDouble())
          ]);
        }).toList()));
  }

  Widget getTiles(double value, TitleMeta meta) {
    return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          barData[value.toInt()].actName,
          style: GoogleFonts.signika(color: Theme.of(context).secondaryHeaderColor, fontSize: 16),
        ));
  }
}
