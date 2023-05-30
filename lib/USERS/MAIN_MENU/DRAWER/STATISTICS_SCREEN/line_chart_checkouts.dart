import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartCheckouts extends StatefulWidget {
  const LineChartCheckouts({super.key});

  @override
  State<LineChartCheckouts> createState() => _LineChartCheckoutsState();
}

class _LineChartCheckoutsState extends State<LineChartCheckouts> {
  @override
  Widget build(BuildContext context) {
    return LineChart(LineChartData());
  }
}
