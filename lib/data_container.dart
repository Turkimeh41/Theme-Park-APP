// ignore_for_file: unused_import, use_build_context_synchronously

import 'package:chalkdart/chalk.dart';
import 'package:final_project/Provider/participations_provider.dart';
import 'package:final_project/stream_listener.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'Provider/activites_provider.dart';
import 'Provider/transactions_provider.dart';
import 'Provider/user_provider.dart' as u;
import 'dart:developer';
import 'splash_screen.dart';
import './Provider/mode_provider.dart';

class DataContainer extends StatefulWidget {
  const DataContainer({super.key});

  @override
  State<DataContainer> createState() => _DataContainerState();
}

class _DataContainerState extends State<DataContainer> {
  ValueNotifier<int> rocketNotifier = ValueNotifier(0);
  ValueNotifier<String> textNotifier = ValueNotifier('Fetching Activites');

  Future<void> fetchDataContainers(BuildContext context) async {
    log('Fetching Activites...');
    await Provider.of<Activites>(context, listen: false).fetchActivites();
    log('Fetching Participations...');
    await Provider.of<Participations>(context, listen: false).fetchParticipations();
    await Future.delayed(const Duration(milliseconds: 1300));
    textNotifier.value = ("Fetching Transactions...");
    await Future.delayed(const Duration(milliseconds: 600));
    await Provider.of<Transactions>(context, listen: false).fetchTransactions();
    textNotifier.value = ("fetching and setting\n up user information");
    await Future.delayed(const Duration(milliseconds: 1000));
    await Provider.of<u.User>(context, listen: false).setUser();

    textNotifier.value = "Done!";
    rocketNotifier.value = 1;
    await Future.delayed(const Duration(milliseconds: 1200));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchDataContainers(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(rocketNotifier: rocketNotifier, textNotifier: textNotifier);
          } else {
            return const StreamListener();
          }
        });
  }
}
