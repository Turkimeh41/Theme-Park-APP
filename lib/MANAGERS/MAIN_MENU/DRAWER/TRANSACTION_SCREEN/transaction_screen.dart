import 'package:final_project/MANAGERS/MAIN_MENU/DRAWER/TRANSACTION_SCREEN/transaction_widget.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool ascending = false;
  late TextEditingController searchController;

  @override
  void initState() {
    searchController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<Manager>(context);
    final transactionList = manager.transactions;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Transactions',
          style: GoogleFonts.signika(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0, top: 24, left: 12),
            child: Text(
              'This is all the transactions \n    you\'ve proceeded, take a look!',
              style: GoogleFonts.signika(color: const Color.fromARGB(255, 32, 32, 32), fontSize: 18),
            ),
          ),
          const Divider(
            height: 1,
            color: Color.fromARGB(255, 199, 167, 167),
            thickness: 2,
          ),
          Expanded(
            child: ListView.separated(
                padding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 8),
                itemBuilder: (context, index) {
                  return TransactionWidget(transaction: transactionList[index]);
                },
                separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                itemCount: transactionList.length),
          ),
        ],
      ),
    );
  }
}
