import 'package:final_project/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

bool _loading = false;

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: dh,
        width: dw,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Logged-In!'),
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
                child: !_loading ? const Text('Log out') : const CircularProgressIndicator())
          ],
        ),
      ),
    );
  }
}
