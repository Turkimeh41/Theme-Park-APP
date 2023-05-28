// ignore_for_file: use_build_context_synchronously
import 'package:final_project/Handler/manager_firebase_handler.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/main_menu.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/utility_provider.dart';
import 'package:final_project/USERS/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagerDataContainer extends StatefulWidget {
  const ManagerDataContainer({super.key});

  @override
  State<ManagerDataContainer> createState() => _ManagerDataContainerState();
}

class _ManagerDataContainerState extends State<ManagerDataContainer> {
  final ValueNotifier<int> rocketNotifier = ValueNotifier(0);
  final ValueNotifier<String> textNotifier = ValueNotifier('Fetching Activites');

  Future<void> _fetchData(BuildContext context) async {
    await ManagerFirebaseHandler.setLastLogin();
    await Provider.of<Activites>(context, listen: false).fetchActivites();
    await Future.delayed(const Duration(milliseconds: 1200));
    textNotifier.value = 'Fetching and setting Manager data';
    await Provider.of<Manager>(context, listen: false).setManager();
    await Future.delayed(const Duration(milliseconds: 700));
    textNotifier.value = "Done!";
    rocketNotifier.value = 1;
    await Future.delayed(const Duration(milliseconds: 1200));
  }

  @override
  Widget build(BuildContext context) {
    final utility = Provider.of<Utility>(context);
    utility.initializeManagerENABLEDStream();
    return FutureBuilder(
        future: _fetchData(context),
        builder: (context, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(rocketNotifier: rocketNotifier, textNotifier: textNotifier);
          } else {
            return const ManagerMainMenu();
          }
        });
  }
}
