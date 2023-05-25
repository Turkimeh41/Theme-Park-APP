import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  String currentUserType = '';

  Future<void> getCurrentUser() async {
    final pref = await SharedPreferences.getInstance();
    final currentUser = (pref.get('type') ?? '') as String;
    currentUserType = currentUser;
  }

  Future<void> checkRememberME() async {
    final pref = await SharedPreferences.getInstance();
    bool? value = pref.getBool('remember-me') ?? true;

    //remember me is true!
    if (value) {
      return;
    } else if (!value) {
      await FirebaseAuth.instance.signOut();
      currentUserType = '';
      pref.remove('remember-me');
    }
  }

  Future<void> clearCurrentUser() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('type');
  }
}
