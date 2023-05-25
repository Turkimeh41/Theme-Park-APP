import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralHandler {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await FirebaseFunctions.instanceFor(region: "europe-west1").httpsCallable('login').call({'username': username, 'password': password});
    return {"customToken": result.data['token'], "type": result.data['type']};
  }

  static Future<void> loginToken(String token) async {
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }

  static Future<void> setCurrentUser(String type) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('type', type);
  }
}
