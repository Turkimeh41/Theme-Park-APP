import 'package:flutter/material.dart';

class EngagingScreen extends StatefulWidget {
  const EngagingScreen({super.key});

  @override
  State<EngagingScreen> createState() => _EngagingScreenState();
}

class _EngagingScreenState extends State<EngagingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('ENGAGED!'),
    );
  }
}
