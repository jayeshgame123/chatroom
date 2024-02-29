import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Screens/Settings/AccountSetting.dart';
import 'package:chat_app/Screens/Settings/ThemeSetting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SettingScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SettingScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Settings"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountSetting(
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseUser)));
                  },
                  child: const ListTile(
                    leading: Icon(Icons.key),
                    title: Text(
                      "Account",
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Text("Reset password, Delete account"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ThemeSetting(
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseUser)));
                  },
                  child: const ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Text(
                      "Theme",
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Text("Theme mode"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
