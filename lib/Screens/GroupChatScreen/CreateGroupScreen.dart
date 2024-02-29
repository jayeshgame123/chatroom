import 'dart:io';
import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/GroupChatRoom.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Screens/GroupChatScreen/GroupChatRoomScreen.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CreateGroupScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController groupNameController = TextEditingController();
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

  void checkCreateGroupValues() {
    String groupName = groupNameController.text.trim();
    if (groupName == "" || imageFile == null) {
      print("empty");
      Constants.showWarningToastOnly("Please complete the profile.");
    } else {
      createGroup();
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

  void createGroup() async {
    showLoaderDialog(context);
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("grouppictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String groupName = groupNameController.text.trim();

    GroupChatUserModel userModel = GroupChatUserModel(
        email: widget.userModel.email,
        fullName: widget.userModel.fullName,
        profilePic: widget.userModel.profilePic,
        uid: widget.userModel.uid,
        userName: widget.userModel.userName,
        currentlyActiveChatRoomID: widget.userModel.currentlyActiveChatRoomID,
        isInChatRoom: widget.userModel.isInChatRoom);

    GroupChatRoomModel newGroupChatRoom = GroupChatRoomModel(
        chatRoomId: uuid.v1(),
        participants: {
          widget.userModel.uid.toString(): true,
        },
        lastMessage: "",
        users: [widget.userModel.uid.toString()],
        createdOn: DateTime.now(),
        updatedOn: DateTime.now(),
        groupChatUsersDetail: [userModel],
        groupName: groupName,
        groupPic: imageUrl,
        isLastMessageSeen: true,
        lastMsgSender: widget.userModel.uid,
        createdBy: widget.userModel.uid);

    await FirebaseFirestore.instance
        .collection("groupchatrooms")
        .doc(newGroupChatRoom.chatRoomId)
        .set(newGroupChatRoom.toJson());

    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GroupChatRoomScreen(
                groupChatRoomModel: newGroupChatRoom,
                userModel: widget.userModel,
                firebaseUser: widget.firebaseUser)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // automaticallyImplyLeading: false,
          title: const Text("Create New Group"),
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
              controller: groupNameController,
              decoration: const InputDecoration(labelText: "Group Name"),
            ),
            const SizedBox(height: 40),
            CupertinoButton(
              onPressed: () {
                checkCreateGroupValues();
              },
              color: Colors.blue,
              child: const Text("Create Group"),
            )
          ]),
        )));
  }
}
