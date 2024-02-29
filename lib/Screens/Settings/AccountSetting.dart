import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AccountSetting extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const AccountSetting({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Account"),
      ),
      body: SafeArea(child: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    FirebaseAuth.instance
                              .sendPasswordResetEmail(
                                  email: widget.userModel.email!)
                              .then((value) {
                            Constants.showWarningToastOnly("Reset request is sended to registered email");
                          }).onError((error, stackTrace){
                            print("Error:$error");
                          });
                  },
                  child: ListTile(
                        leading: Icon(Icons.security),
                        title: Text(
                          "Reset password",
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      ),
                ),
                
                    InkWell(
                      onTap: () {
                        
                      },
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text(
                          "Delete account",
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: const Icon(Icons.keyboard_arrow_right),
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