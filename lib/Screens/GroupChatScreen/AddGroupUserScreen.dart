import 'dart:developer';

import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/GroupChatRoom.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:chat_app/Screens/ChatRoomScreen.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

class AddGroupUserScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final GroupChatRoomModel groupChatRoomModel;

  const AddGroupUserScreen(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.groupChatRoomModel});

  @override
  State<AddGroupUserScreen> createState() => _AddGroupUserScreenState();
}

class _AddGroupUserScreenState extends State<AddGroupUserScreen> {
  TextEditingController searchUserNameController = TextEditingController();
  // GroupChatRoomModel? groupChatRoomModel;

  Future<GroupChatRoomModel?> addUserInGroupChatRoomModel(
      UserModel targetUser) async {
    List<dynamic>? groupUserList = widget.groupChatRoomModel.users;
    List<GroupChatUserModel>? groupChatUsersDetail =
        widget.groupChatRoomModel.groupChatUsersDetail;

    bool isUserAlreadyExistInGroup = false;
    if (groupUserList!.isNotEmpty) {
      for (int i = 0; i < groupUserList.length; i++) {
        if (targetUser.uid == groupUserList[i]) {
          isUserAlreadyExistInGroup = true;
          break;
        }
      }
    }

    if (!isUserAlreadyExistInGroup) {
      GroupChatUserModel targetUserModel = GroupChatUserModel(
          email: targetUser.email,
          fullName: targetUser.fullName,
          profilePic: targetUser.profilePic,
          uid: targetUser.uid,
          userName: targetUser.userName,
          currentlyActiveChatRoomID: targetUser.currentlyActiveChatRoomID,
          isInChatRoom: targetUser.isInChatRoom);

      groupUserList.add(targetUserModel.uid);
      groupChatUsersDetail!.add(targetUserModel);

      widget.groupChatRoomModel.users = groupUserList;
      widget.groupChatRoomModel.groupChatUsersDetail = groupChatUsersDetail;

      await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoomModel.chatRoomId)
          .set(widget.groupChatRoomModel.toJson());
      // chatRoomModel = newChatRoom;
      log("Group chat room member added");
    } else {
      Constants.showWarningToastOnly("Already added in group");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Search Friends"),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(children: [
          const SizedBox(height: 20),
          TextField(
            controller: searchUserNameController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search Username",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(60)),
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 30),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("user")
                .orderBy("userName")
                  .startAt([searchUserNameController.text])
                  .endAt([searchUserNameController.text + "\uf8ff"])
                  .where("userName", isNotEqualTo: widget.userModel.userName)
                .snapshots(),
            builder: (context, snapshot) {
              if (searchUserNameController.text.isNotEmpty) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      UserModel searchedUser =
                          UserModel.fromJson(snapshot.data!.docs[0].data());
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilePic!),
                        ),
                        title: Text(searchedUser.fullName.toString()),
                        subtitle: Text(searchedUser.userName.toString()),
                        trailing: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("groupchatrooms")
                                .where("chatRoomId", isEqualTo: widget.groupChatRoomModel.chatRoomId)
                                .where("users", arrayContains: searchedUser.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.docs.isNotEmpty) {
                                    GroupChatRoomModel existingGroupChatRoom =
                                        GroupChatRoomModel.fromJson(
                                            snapshot.data!.docs[0].data());
                                    return Icon(
                                      Icons.check, color: Colors.grey
                                      );
                                        
                                  } else {
                                    return IconButton(
                                        onPressed: () {
                                          // chatRoom =
                                          //     await getChatRoomModel(
                                          //         searchedUser);
                                          addUserInGroupChatRoomModel(
                                              searchedUser);
                                          Constants.showWarningToastOnly("Added in group");
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.person_add_alt_1,
                                          color: themeProvider.themeMode ==
                                                  ThemeMode.light
                                              ? Colors.blue
                                              : Colors.white,
                                        ));
                                  }
                                } else {
                                  return Text("");
                                }
                              } else {
                                return Text("");
                              }
                            }),
                      );
                    } else {
                      return const Text("No result found!");
                    }
                  } else if (snapshot.hasError) {
                    return const Text("An error occured!");
                  } else {
                    return const Text("No result found!");
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              } else {
                return const Text("");
              }
            },
          )
        ]),
      )),
    );
  }
}
