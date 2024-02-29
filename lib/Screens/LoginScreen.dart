import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Screens/CompleteProfileScreen.dart';
import 'package:chat_app/Screens/ForgetPasswordScreen.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/Screens/SignupScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hidePass = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Chat Room",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: hidePass,
                  decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePass = !hidePass;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye))),
                ),
                // const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgetPasswordScreen()));
                      },
                      child: const Text("Forget password?",
                          style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  onPressed: () {
                    checkLoginValues();
                  },
                  color: Colors.blue,
                  child: const Text("Login"),
                )
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?",
                style: TextStyle(fontSize: 16)),
            CupertinoButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()));
                },
                child: const Text("Sign up", style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  void checkLoginValues() {
    String email = emailController.text.trim();
    String pass = passwordController.text.trim();
    if (email == "" || pass == "") {
      Constants.showWarningToastOnly("Email or password is empty");
    } else {
      login(email, pass);
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void login(String email, String pass) async {
    showLoaderDialog(context);
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (e) {
      print(e.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("user").doc(uid).get();
      UserModel userModel =
          UserModel.fromJson(userData.data() as Map<String, dynamic>);

      print("Login Success");
      Navigator.pop(context);
      if (userModel.fullName == "" || userModel.profilePic == null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CompleteProfileScreen(
                    userModel: userModel, firebaseUser: credential!.user!)));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                    userModel: userModel, firebaseUser: credential!.user!)));
      }
    } else {
      Navigator.pop(context);
      Constants.showWarningToastOnly("Invalid credentials.");
    }
  }
}
