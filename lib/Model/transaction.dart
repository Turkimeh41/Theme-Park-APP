// ignore_for_file: non_constant_identifier_names

class Transaction {
  final String transID;
  final String actName;
  final String actIMG;
  final DateTime transaction_date;
  final double actAmount;
  final String actType;
  final int actDuration;
  String? label;
  String? anonymousID;
  Transaction(
      {required this.transID,
      required this.actName,
      required this.actIMG,
      required this.transaction_date,
      required this.actAmount,
      required this.actType,
      required this.actDuration,
      this.label,
      this.anonymousID});
}
