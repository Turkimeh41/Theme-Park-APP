import 'package:final_project/Model/transaction.dart';
import 'package:flutter/material.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({required this.transaction, super.key});
  final Transaction transaction;
  @override
  Widget build(BuildContext context) {
    return Card(shadowColor: Colors.black, child: Container(padding: const EdgeInsets.all(12), height: 80, child: Row(), decoration: const BoxDecoration(color: Color.fromARGB(255, 228, 208, 208))));
  }
}
