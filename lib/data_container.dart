// ignore_for_file: unused_import

import 'package:final_project/Provider/participations_provider.dart';
import 'package:final_project/stream_listener.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'Provider/activites_provider.dart';
import 'Provider/transactions_provider.dart';
import 'Provider/user_provider.dart' as u;
import 'dart:developer';
import 'splash_screen.dart';

class DataContainer extends StatefulWidget {
  const DataContainer({super.key});

  @override
  State<DataContainer> createState() => _DataContainerState();
}

Future<void> fetchDataContainers(BuildContext context) async {
  log('Fetching data Containers...');
  await Future.wait([
    Provider.of<Transactions>(context, listen: false).fetchTransactions(),
    Provider.of<Activites>(context, listen: false).fetchActivites(),
    Provider.of<u.User>(context, listen: false).setUser(),
  ]);
  log('Done!');
  await Future.delayed(const Duration(seconds: 4));
}

class _DataContainerState extends State<DataContainer> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Transactions(),
        ),
        ChangeNotifierProvider(
          create: (context) => Activites(),
        ),
        ChangeNotifierProvider(
          create: (context) => u.User(),
        ),
        ChangeNotifierProvider(
          create: (context) => Participations(),
        )
      ],
      builder: (context, child) {
        return FutureBuilder(
            future: fetchDataContainers(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              } else {
                return const StreamListener();
              }
            });
      },
    );
  }
}
