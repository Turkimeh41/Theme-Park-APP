import 'package:final_project/USERS/MAIN_MENU/DRAWER/TRANSACTION_SCREEN/transaction_widget.dart';
import 'package:final_project/USERS/Provider/transactions_provider.dart';
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
    final transactions = Provider.of<Transactions>(context);
    final transactionList = transactions.filter(ascending, searchController.text);
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Transactions',
            style: GoogleFonts.signika(color: Colors.white, fontSize: 18),
          ),
        ),
        body: Container(
          color: const Color.fromARGB(255, 243, 235, 235),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: dw,
                      height: 50,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 8,
                              bottom: 10,
                              child: Text(
                                'Sort by',
                                style: GoogleFonts.signika(color: const Color.fromARGB(255, 109, 56, 81), fontSize: 17.5),
                              )),
                          Positioned(
                              bottom: 8,
                              left: 85,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    ascending = !ascending;
                                  });
                                },
                                child: Text(
                                  'Date',
                                  style: GoogleFonts.signika(color: const Color.fromARGB(255, 95, 3, 46), fontSize: 20),
                                ),
                              )),
                          Positioned(
                              bottom: 8,
                              left: 120,
                              child: Icon(
                                ascending ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                                color: const Color.fromARGB(255, 119, 109, 109),
                              )),
                          Positioned(
                              right: 0,
                              bottom: 25,
                              child: RichText(
                                  text: TextSpan(
                                      children: [TextSpan(text: transactions.transactions.length.toString(), style: GoogleFonts.signika(fontSize: 18, fontWeight: FontWeight.bold))],
                                      text: 'Total Transactions: ',
                                      style: GoogleFonts.signika(color: const Color.fromARGB(255, 109, 56, 81), fontSize: 14)))),
                          Positioned(
                              right: 0,
                              bottom: 5,
                              child: RichText(
                                  text: TextSpan(
                                      style: GoogleFonts.signika(color: const Color.fromARGB(255, 109, 56, 81), fontSize: 14),
                                      children: [TextSpan(text: '${transactions.totalExpenses.toStringAsFixed(2)} SAR', style: GoogleFonts.signika(fontSize: 18, fontWeight: FontWeight.bold))],
                                      text: 'Total Expenses: ')))
                        ],
                      )),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  height: 40,
                  width: 275,
                  child: TextField(
                    onChanged: (_) {
                      setState(() {});
                    },
                    controller: searchController,
                    style: GoogleFonts.signika(color: const Color.fromARGB(255, 109, 56, 81)),
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                        hintStyle: GoogleFonts.signika(color: const Color.fromARGB(255, 116, 65, 88)),
                        hintText: 'Search by name',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 2, right: 0),
                          child: Icon(
                            size: 32,
                            Icons.search,
                            color: Color.fromARGB(255, 95, 3, 46),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 230, 208, 205),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Color.fromARGB(255, 211, 198, 198),
                  thickness: 1.75,
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
          ),
        ));
  }
}
