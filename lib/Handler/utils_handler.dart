// ignore_for_file: use_build_context_synchronously

import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:final_project/USERS/Provider/participations_provider.dart';
import 'package:final_project/USERS/Provider/transactions_provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UtilityHandler {
  static Future<void> refresh(BuildContext context) async {
    await Provider.of<Activites>(context, listen: false).fetchActivites();
    await Provider.of<Participations>(context, listen: false).fetchParticipations();
    await Provider.of<Transactions>(context, listen: false).fetchTransactions();
    await Provider.of<User>(context, listen: false).setUser();
  }
}
