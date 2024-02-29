import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Screens/CompleteProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool hidePass = true;
  bool hideConfirmPass = true;

  void checkSignupValues() async {
    String email = emailController.text.trim();
    String userName = userNameController.text.trim();
    String pass = passwordController.text.trim();
    String confirmPass = confirmPasswordController.text.trim();

    if (email == "") {
      Constants.showWarningToastOnly("Email is empty.");
      return;
    }
    if (userName == "") {
      Constants.showWarningToastOnly("Username is empty.");
      return;
    }
    if (userName.isNotEmpty) {
      var userData = await FirebaseFirestore.instance
          .collection("user")
          .where("userName", isEqualTo: userName)
          .get();
      print(userData);
      if (userData.docs.isNotEmpty) {
        Constants.showWarningToastOnly("Username is already taken.");
        return;
      }
    }
    if (pass == "") {
      Constants.showWarningToastOnly("Password is empty.");
      return;
    }
    if (confirmPass == "") {
      Constants.showWarningToastOnly("Confirm password is empty.");
      return;
    }
    if (pass != confirmPass) {
      Constants.showWarningToastOnly(
          "Password not match with confirm password.");
    } else {
      signUp(email, pass, userName);
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

  void signUp(String email, String pass, String userName) async {
    showLoaderDialog(context);
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (e) {
      print(e.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
          uid: uid,
          fullName: "",
          userName: userName,
          email: email,
          profilePic: "",
          currentlyActiveChatRoomID: "",
          isInChatRoom: false,
          status: "",
          lastSeen: DateTime.now());
      await FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .set(newUser.toJson())
          .then((value) {
        print("New User created");
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return CompleteProfileScreen(
              userModel: newUser, firebaseUser: credential!.user!);
        }));
      });
    } else {
      Navigator.pop(context);
      Constants.showWarningToastOnly("Something wnt wrong!.");
    }
  }

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
                  "Sign Up",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email Address"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(labelText: "User Name"),
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
                const SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirmPass,
                  decoration: InputDecoration(
                      labelText: "Confirm Password",
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hideConfirmPass = !hideConfirmPass;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye))),
                ),
                const SizedBox(height: 40),
                CupertinoButton(
                  onPressed: () {
                    checkSignupValues();
                  },
                  color: Colors.blue,
                  child: const Text("Sign Up"),
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
            const Text("Already have an account?",
                style: TextStyle(fontSize: 16)),
            CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Login", style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
