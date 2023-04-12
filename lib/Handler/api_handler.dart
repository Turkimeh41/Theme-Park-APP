// ignore_for_file: non_constant_identifier_names

import 'package:permission_handler/permission_handler.dart';

class ApiHandler {
  static Future<PermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status;
  }
}
