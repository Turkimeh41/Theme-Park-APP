import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:final_project/network_unaviliable.dart';

class Network {
  static Future<bool> validateNetwork() async {
    await Future.delayed(const Duration(seconds: 1));
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      Get.to(() => const NetworkUnaviliableScreen());
      return false;
    } else if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.

      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      return true;
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      // I am connected to a ethernet network.
      return true;
    } else if (connectivityResult == ConnectivityResult.vpn && connectivityResult == ConnectivityResult.none) {
      Get.to(() => const NetworkUnaviliableScreen());
      return false;
    } else if (connectivityResult == ConnectivityResult.bluetooth && connectivityResult == ConnectivityResult.none) {
      Get.to(() => const NetworkUnaviliableScreen());
      return false;
    } else if (connectivityResult == ConnectivityResult.other) {
      Get.back();
      return false;
    }
    return false;
  }

  static Future<void> tryNetwork() async {
    await Future.delayed(const Duration(seconds: 1));
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return;
    } else if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.

      Get.back();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      Get.back();
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      // I am connected to a ethernet network.
      Get.back();
    } else if (connectivityResult == ConnectivityResult.vpn && connectivityResult == ConnectivityResult.none) {
      return;
    } else if (connectivityResult == ConnectivityResult.bluetooth && connectivityResult == ConnectivityResult.none) {
      return;
    } else if (connectivityResult == ConnectivityResult.other) {
      Get.back();
    }
  }
}
