import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeneralHandler {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await FirebaseFunctions.instanceFor(region: "europe-west1").httpsCallable('login').call({'username': username, 'password': password});
    return {"customToken": result.data['token'], "type": result.data['type']};
  }

  static Future<void> signInWithCustomToken(String token) async {
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }
}
