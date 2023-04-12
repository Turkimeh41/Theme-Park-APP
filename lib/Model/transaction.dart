// ignore_for_file: non_constant_identifier_names

class Transaction {
  final String actID;
  final String activityName;
  final DateTime transaction_date;
  final double price;
  final String type;
  Transaction(this.actID, this.activityName, this.transaction_date, this.price, this.type);
}
