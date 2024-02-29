import 'dart:io';

import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ProfileScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  File? imageFile;
  bool hidePass = true;
  bool hideConfirmPass = true;
  late UserModel userModel;
  late User firebaseUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userModel = widget.userModel;
    firebaseUser = widget.firebaseUser;
    // imageFile = userModel.profilePic;
    emailController.text = userModel.email.toString();
    userNameController.text = userModel.userName.toString();
    fullNameController.text = userModel.fullName.toString();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 63,
                  backgroundColor: themeProvider.themeMode == ThemeMode.light ? Colors.blue: Colors.grey,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(userModel.profilePic!),
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    showPhotoOptionDailog();
                  },
                  child: const Text("Change Photo"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(labelText: "User Name"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  enabled: false,
                  decoration: const InputDecoration(labelText: "Email Address"),
                ),
                const SizedBox(height: 40),
                CupertinoButton(
                  onPressed: () {
                    checkUpdateProfileValues();
                  },
                  color: Colors.blue,
                  child: const Text("Update Profile"),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  void selectImage(ImageSource imageSource) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: imageSource);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile pickedFile) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);

    if (croppedFile != null) {
      showLoaderDialog(context);
      imageFile = croppedFile;
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("profilepictures")
          .child(widget.userModel.uid.toString())
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      widget.userModel.profilePic = imageUrl;
      Navigator.pop(context);
      setState(() {});
      Constants.showWarningToastOnly("Profile photo changed successfully");
    }
  }

  void showPhotoOptionDailog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Pic"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void updateProfile(
      updatedEmail, updatedUserName, updatedFullName, imageFile) async {
    showLoaderDialog(context);

    String fullName = updatedFullName;
    String email = updatedEmail;
    String userName = updatedUserName;

    widget.userModel.fullName = fullName;
    widget.userModel.email = email;
    widget.userModel.userName = userName;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toJson());
    Navigator.pop(context);
    Constants.showWarningToastOnly("Profile updated successfully");
  }

  void checkUpdateProfileValues() {
    String updatedEmail = emailController.text.trim();
    String updatedUserName = userNameController.text.trim();
    String updatedFullName = fullNameController.text.trim();
    if (updatedEmail == "" || updatedUserName == "" || updatedFullName == "") {
      print("empty");
      Constants.showWarningToastOnly("Please complete the profile.");
    } else {
      updateProfile(updatedEmail, updatedUserName, updatedFullName, imageFile);
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
}
