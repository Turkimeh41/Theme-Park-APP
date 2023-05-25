import 'package:cloud_firestore/cloud_firestore.dart';

class AnonymousUser {
  final String id;
  final String? providerAccountID;
  final String? label;
  final String qrURL;
  Timestamp? assignedDate;

  AnonymousUser({required this.id, required this.assignedDate, required this.qrURL, required this.providerAccountID, required this.label});
}
