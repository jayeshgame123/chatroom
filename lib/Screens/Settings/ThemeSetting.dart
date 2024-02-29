import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

class ThemeSetting extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ThemeSetting({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(

      ),
      body: SafeArea(child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: const Text(
                "Choose theme",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            RadioListTile<ThemeMode>(
              title: const Text("Light Mode"),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: themeProvider.setTheme
              ),

              RadioListTile<ThemeMode>(
              title: const Text("Dark Mode"),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: themeProvider.setTheme
              ),
          ],
        ),
      )),
    );
  }
}