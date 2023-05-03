// ignore_for_file: non_constant_identifier_names

class Transaction {
  final String transID;
  final String actID;
  final String activityName;
  final DateTime transaction_date;
  final double amount;
  final String type;
  Transaction(this.transID, this.actID, this.activityName, this.transaction_date, this.amount, this.type);
}
