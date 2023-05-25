// ignore_for_file: non_constant_identifier_names

class Transaction {
  Transaction({required this.id, required this.actID, required this.uID, required this.actName, required this.transaction_date, required this.actIMG, required this.actAmount});
  final String id;
  final String uID;
  final String actID;
  final String actName;
  final double actAmount;
  final String actIMG;
  final DateTime transaction_date;
}
