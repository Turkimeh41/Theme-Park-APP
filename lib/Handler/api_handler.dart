import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiHandler {
  static Future<void> setMetaData(String key, Map<Object?, Object?> iv) async {
    final refList = await FirebaseStorage.instance.ref('qr-codes/users/${FirebaseAuth.instance.currentUser!.uid}').listAll();
    final ref = refList.items.first;
    final newMetadata = SettableMetadata(
      contentType: "image/png",
      customMetadata: {'key': key, 'iv': iv.toString()},
    );
    await ref.updateMetadata(newMetadata);
  }
}
