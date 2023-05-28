import 'package:final_project/Handler/user_firebase_handler.dart';
import 'package:final_project/USERS/Provider/activity_engagement_provider.dart';
import 'package:final_project/USERS/Provider/user_provider.dart';
import 'package:flutter/material.dart';

class EngageHandler {
  EngageHandler(this.currentUser, this.insEngagement);
  final ActivityEngagement insEngagement;
  final User currentUser;
  TextEditingController messageController = TextEditingController();
  FocusNode messageFocus = FocusNode();
  late void Function(void Function()) setState;

  Future<void> sendMessage() async {
    bool valid = _validateMessage();
    if (!valid) {
      return;
    }

    await UserFirebaseHandler.sendMessage(currentUser, messageController.text, insEngagement.currentActivity!.id);
    setState(() {
      messageController.text = '';
    });
  }

  bool _validateMessage() {
    if (messageController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }
}
