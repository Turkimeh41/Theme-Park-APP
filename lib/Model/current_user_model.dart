// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class CurrentUser {
  CurrentUser({required this.imgURL, required this.id, required this.label, required this.first_name, required this.last_name, required this.username, this.valueNotifier});
  final String id;
  final String? username;
  final String? label;
  final String? first_name;
  final String? last_name;
  final String? imgURL;
  final ValueNotifier<String>? valueNotifier;
}
