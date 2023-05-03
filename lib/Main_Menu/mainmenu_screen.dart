// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:final_project/Main_Menu/qr_view.dart';
import 'package:final_project/Provider/user_provider.dart' as u;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    final user = Provider.of<u.User>(context, listen: false);

    return Scaffold(
        body: SizedBox(
      height: dh,
      width: dw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            child: user.userImg_link != 'null'
                ? CircleAvatar(radius: 36, backgroundImage: CachedNetworkImageProvider(user.userImg_link))
                : const CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage('assets/images/placeholder.png'),
                  ),
            onTap: () async {
              await user.editPicture(setState, user.userImg_link);
            },
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('setState')),
          ElevatedButton(
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                await FirebaseAuth.instance.signOut();
                setState(() {
                  _loading = false;
                });
                Get.off(() => const LoginScreen());
              },
              child: !_loading ? const Text('Log out') : const CircularProgressIndicator()),
          ElevatedButton(
              child: const Text('Camera QR'),
              onPressed: () async {
                Get.to(const QRViewScreen());
              }),
        ],
      ),
    ));
  }
}
