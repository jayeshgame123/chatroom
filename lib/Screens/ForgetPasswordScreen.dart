import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Chat Room",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                const TextField(
                  // controller: emailController,
                  decoration: InputDecoration(labelText: "Email Address"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Note: The link for the reset password will be share to your email address",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                CupertinoButton(
                  onPressed: () {
                    // checkLoginValues();
                  },
                  color: Colors.blue,
                  child: const Text("Reset Password"),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
