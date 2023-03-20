import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

bool loading = false;

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('LoggedIN!'),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                });
                Future.delayed(const Duration(milliseconds: 1500), () {
                  FirebaseAuth.instance.signOut();
                });
              },
              child: !loading ? Text('Log out') : CircularProgressIndicator())
        ],
      ),
    );
  }
}
