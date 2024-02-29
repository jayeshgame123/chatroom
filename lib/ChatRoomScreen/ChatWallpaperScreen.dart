import 'dart:io';

import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ChatWallPaperScreen extends StatefulWidget {
  // final ChatUserModel? targetUser;
  final ChatRoomModel chatRoomModel;
  final UserModel userModel;
  final User firebaseUser;

  const ChatWallPaperScreen(
      {super.key,
      required this.chatRoomModel,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatWallPaperScreen> createState() => _ChatWallPaperScreenState();
}

class _ChatWallPaperScreenState extends State<ChatWallPaperScreen> {
  File? imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 250,
                  height: 430,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      image: imageFile != null
                          ? DecorationImage(
                              image: FileImage(imageFile!), fit: BoxFit.cover)
                          : null
                      // color: Colors.amber,
                      ),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        color: Colors.blue,
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 3,
                                ),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: const Flexible(
                                child: Text("Enter message",
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Icon(
                                  Icons.attach_file,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.send, color: Colors.black),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // const SizedBox(height: 20),

                CupertinoButton(
                    child: const Text("Select Wallpaper"),
                    onPressed: () {
                      selectImage(ImageSource.gallery);
                    }),
                const SizedBox(height: 20),

                CupertinoButton(
                    color: Colors.blue,
                    onPressed: () {
                      setWallpaper();
                    },
                    child: const Text("Set Wallpaper"))
              ],
            ),
          ),
        ));
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

  void selectImage(ImageSource imageSource) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: imageSource);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile pickedFile) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);

    if (croppedFile != null) {
      showLoaderDialog(context);
      imageFile = croppedFile;
      Navigator.pop(context);
      setState(() {});
    }
  }

  void setWallpaper() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("wallpapers")
        .child(widget.chatRoomModel.chatRoomId.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    widget.chatRoomModel.chatWallpaper = imageUrl;

    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatRoomModel.chatRoomId)
        .update(widget.chatRoomModel.toJson());

    Constants.showWarningToastOnly("Wallpaper changed successfully");
  }
}
