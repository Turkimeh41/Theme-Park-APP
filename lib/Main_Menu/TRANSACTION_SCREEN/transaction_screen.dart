import 'package:final_project/Main_Menu/TRANSACTION_SCREEN/transaction_widget.dart';
import 'package:final_project/Provider/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});
  static const route = "/transaction";
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int sortBy = 0;
  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<Transactions>(context);
    final transactionList = transactions.transactions;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Transactions',
            style: GoogleFonts.signika(color: Colors.white, fontSize: 24),
          ),
        ),
        body: Container(
          color: const Color.fromARGB(255, 243, 235, 235),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return TransactionWidget(transaction: transactionList[index]);
              },
              separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: Color.fromARGB(255, 211, 198, 198),
                    thickness: 1.25,
                  ),
              itemCount: transactionList.length),
        ));
  }
}


/* const Color.fromARGB(255, 109, 56, 81) */

/* const Color.fromARGB(255, 95, 3, 46) */