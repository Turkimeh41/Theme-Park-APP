import 'dart:developer';

import 'package:final_project/Exception/balance_exception.dart';
import 'package:final_project/Handler/firebase_handler.dart';
import 'package:final_project/Provider/activites_provider.dart';
import 'package:final_project/Provider/participations_provider.dart';
import 'package:final_project/Provider/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/Provider/user_provider.dart' as u;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<u.User>(context, listen: false);
    final activity = Provider.of<Activites>(context, listen: false).activites[0];
    final transaction = Provider.of<Transactions>(context, listen: false);
    final participation = Provider.of<Participations>(context, listen: false);
    return Center(
      child: ElevatedButton(
          onPressed: () async {
            try {
              await user.attemptPayment(activity);
              //payment should have deduced
              await user.switchEngagement(activity.duration);

              //we will attempt a payment first, if user has insufficent balance, a balanceException error will be thrown, where we won't add a transaction if that happened
              transaction.addTransaction(activity);
              participation.addParticipation(activity);
              //increment one played activity to activites database
              FirebaseHandler.incrementOnePlayedActivity(activity.id);
            } on BalanceException catch (e) {
              log(e.code);
              log(e.details);
            }
          },
          child: const Text('Attempt payment')),
    );
  }
}
