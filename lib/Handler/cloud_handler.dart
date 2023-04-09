import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

//This is the instance of my firebase cloud functions object, which has all the functions i've created
final function = FirebaseFunctions.instanceFor(region: "europe-west1");

class CloudHandler {
  static Future<String> sendSMSTwilio(String phone) async {
    final response = await function.httpsCallable('sendSMSTwilio').call({'phone_number': "+966${phone.replaceAll(RegExp(r"\s+\b|\b\s"), '')}"});
    return response.data['smscode'];
  }

  static Future<void> userExists(String username, String email, String phone) async {
    await function.httpsCallable('existsUser').call({'username': username, 'emailAddress': email, 'number': phone});
  }

  static Future<Map<String, dynamic>> addUser(String username, String password, String firstName, String lastName, String email, String phone, int gender) async {
    final response = await function
        .httpsCallable('addUser')
        .call({'username': username, 'password': password, 'first_name': firstName, 'last_name': lastName, 'emailAddress': email, 'gender': gender, 'number': phone});
    log('token is: ${response.data['token']}');
    log('key is: ${response.data['key']}');
    log('iv is: ${response.data['iv']}');
    return {'token': response.data['token'], 'key': response.data['key'], 'iv': response.data['iv']};
  }

  static Future<String> loginUser(String username, String password) async {
    final result = await function.httpsCallable('loginUser').call({'username': username, 'password': password});
    return result.data['token'];
  }

  static Future<void> login(String token) async {
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }
}
