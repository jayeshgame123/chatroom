import 'package:chat_app/Models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';

class Constants {
  static Color meChatColor = HexColor("#e6e6e6");
  static Color youChatColor = Colors.blue.shade400;
  static Color darkMeChatColor = const Color.fromARGB(255, 42, 39, 39);
  static Color darkYouChatColor = const Color.fromARGB(255, 31, 26, 26);

  static void showWarningToastOnly(String message) {
    if (message == null) return;
    if (message.trim() == "") return;

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM_LEFT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void setStatus(UserModel userModel, String status) async {
    userModel.status = status;
    if (status == "offline") {
      userModel.lastSeen = DateTime.now();
    }
    await FirebaseFirestore.instance
        .collection("user")
        .doc(userModel.uid)
        .update(userModel.toJson());
  }
}
