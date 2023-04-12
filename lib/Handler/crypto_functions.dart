// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class Crypto {
  static String decryptActivityID(String encryptedMessage, String keyHex, String ivHex) {
    final key = hex.decode(keyHex);
    final iv = hex.decode(ivHex);
    final encryptedBytes = hex.decode(encryptedMessage);
    final cipher = CTRStreamCipher(AESFastEngine());
    cipher.init(false, ParametersWithIV<KeyParameter>(KeyParameter(Uint8List.fromList(key)), Uint8List.fromList(iv)));
    final decryptedBytes = cipher.process(Uint8List.fromList(encryptedBytes));
    String decryptedID = utf8.decode(decryptedBytes);
    return decryptedID;
  }
}
