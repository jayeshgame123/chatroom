import 'dart:io';
import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfileScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  TextEditingController fullNameController = TextEditingController();
  File? imageFile;

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
      setState(() {
        imageFile = croppedFile;
      });
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

  void checkCompleteProfileValues() {
    String fullName = fullNameController.text.trim();
    if (fullName == "" || imageFile == null) {
      print("empty");
      Constants.showWarningToastOnly("Please complete the profile.");
    } else {
      completeProfile();
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

  void completeProfile() async {
    showLoaderDialog(context);
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullName = fullNameController.text.trim();

    widget.userModel.fullName = fullName;
    widget.userModel.profilePic = imageUrl;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toJson());
        
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                userModel: widget.userModel,
                firebaseUser: widget.firebaseUser)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text("Complete Profile"),
        ),
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ListView(children: [
            const SizedBox(height: 20),
            CupertinoButton(
              onPressed: () {
                showPhotoOptionDailog();
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    imageFile != null ? FileImage(imageFile!) : null,
                child: imageFile == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 40),
            CupertinoButton(
              onPressed: () {
                checkCompleteProfileValues();
              },
              color: Colors.blue,
              child: const Text("Complete"),
            )
          ]),
        )));
  }
}
