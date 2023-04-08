import 'package:cloud_functions/cloud_functions.dart';

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

  static Future<String> addUser(String username, String password, String firstName, String lastName, String email, String phone, int gender) async {
    final response = await function
        .httpsCallable('addUser')
        .call({'username': username, 'password': password, 'first_name': firstName, 'last_name': lastName, 'emailAddress': email, 'gender': gender, 'number': phone});

    return response.data['token'];
  }

  static Future<String> loginUser(String username, String password) async {
    final result = await function.httpsCallable('loginUser').call({'username': username, 'password': password});
    return result.data['token'];
  }
}
