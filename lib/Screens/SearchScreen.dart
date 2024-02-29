import 'dart:developer';

import 'package:chat_app/Models/ChatRoomModel.dart';
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

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchUserNameController = TextEditingController();
  ChatRoomModel? chatRoomModel;
  ChatRoomModel? chatRoom;

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    ChatUserModel userModel = ChatUserModel(
        email: widget.userModel.email,
        fullName: widget.userModel.fullName,
        profilePic: widget.userModel.profilePic,
        uid: widget.userModel.uid,
        userName: widget.userModel.userName,
        currentlyActiveChatRoomID: widget.userModel.currentlyActiveChatRoomID,
        isInChatRoom: widget.userModel.isInChatRoom);
    ChatUserModel targetUserModel = ChatUserModel(
        email: targetUser.email,
        fullName: targetUser.fullName,
        profilePic: targetUser.profilePic,
        uid: targetUser.uid,
        userName: targetUser.userName,
        currentlyActiveChatRoomID: targetUser.currentlyActiveChatRoomID,
        isInChatRoom: targetUser.isInChatRoom);

    if (snapshot.docs.isNotEmpty) {
      log("chat room already exist");
      ChatRoomModel existingChatRoom = ChatRoomModel.fromJson(
          snapshot.docs[0].data() as Map<String, dynamic>);
      chatRoomModel = existingChatRoom;
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatRoomId: uuid.v1(),
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          lastMessage: "",
          users: [widget.userModel.uid.toString(), targetUser.uid.toString()],
          createdOn: DateTime.now(),
          updatedOn: DateTime.now(),
          chatUsersDetail: [userModel, targetUserModel],
          isReqAccepted: false,
          reqSender: widget.userModel.uid);

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toJson());
      chatRoomModel = newChatRoom;
      log("chat room created");
    }
    return chatRoomModel;
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
        child: SingleChildScrollView(
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
            // CupertinoButton(
            //   onPressed: () {
            //     // setState(() {});
            //   },
            //   color: Colors.blue,
            //   child: const Text("Search"),
            // ),
            const SizedBox(height: 30),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("user")
                  .orderBy("userName")
                  .startAt([searchUserNameController.text])
                  .endAt([searchUserNameController.text + "\uf8ff"])
                  // .where("userName",
                  //     isGreaterThanOrEqualTo: searchUserNameController.text)
                  .where("userName", isNotEqualTo: widget.userModel.userName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (searchUserNameController.text.isNotEmpty) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isNotEmpty) {
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              UserModel searchedUser = UserModel.fromJson(
                                  snapshot.data!.docs[index].data());
                              return ListTile(
                                  // onTap: () async {
                                  //   // if (chatRoom != null) {
                                  //   //   Navigator.pushReplacement(
                                  //   //       context,
                                  //   //       MaterialPageRoute(
                                  //   //           builder: (context) => ChatRoomScreen(
                                  //   //                 targetUser: chatRoom.chatUsersDetail![1],
                                  //   //                 chatRoomModel: chatRoom,
                                  //   //                 userModel: widget.userModel,
                                  //   //                 firebaseUser: widget.firebaseUser,
                                  //   //               )));
                                  //   //   TextButton(onPressed: ()async{
                                  //   //   chatRoom =
                                  //   //       await getChatRoomModel(searchedUser);
                                  //   //       setState(() {
                                  //   //       });
                                  //   // }, child: chatRoom == null ? Text("Add") : Text("Added")),
                                  //   // }
                                  // },
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(searchedUser.profilePic!),
                                  ),
                                  title: Text(searchedUser.fullName.toString()),
                                  subtitle:
                                      Text(searchedUser.userName.toString()),
                                  trailing: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("chatrooms")
                                          .where(
                                              "participants.${widget.userModel.uid}",
                                              isEqualTo: true)
                                          .where(
                                              "participants.${searchedUser.uid}",
                                              isEqualTo: true)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.active) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.docs.isNotEmpty) {
                                              ChatRoomModel existingChatRoom =
                                                  ChatRoomModel.fromJson(snapshot
                                                      .data!.docs[0]
                                                      .data());
                                              return existingChatRoom.reqSender ==
                                                      widget.userModel.uid
                                                  ? Icon(Icons.check,color: Colors.grey)
                                                  : existingChatRoom.isReqAccepted!
                                                  ? Icon(Icons.check,color:Colors.grey)
                                                  :TextButton(
                                                      onPressed: () {
                                                        reqAccepted(existingChatRoom);
                                                      },
                                                      child: const Text("Accept"));
                                            } else {
                                              return IconButton(
                                                  onPressed: () async {
                                                    chatRoom =
                                                        await getChatRoomModel(
                                                            searchedUser);
                                                  },
                                                  icon: Icon(
                                                      Icons.person_add_alt_1,color: themeProvider.themeMode == ThemeMode.light ? Colors.blue: Colors.white,));
                                            }
                                          } else {
                                            return Text("");
                                          }
                                        } else {
                                          return Text("");
                                        }
                                      }));
                            });
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
        ),
      )),
    );
  }
  
  void reqAccepted(ChatRoomModel chatRoomModel) async {
    ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: chatRoomModel.chatRoomId,
        participants: chatRoomModel.participants,
        lastMessage: "",
        users: chatRoomModel.users,
        createdOn: DateTime.now(),
        updatedOn: DateTime.now(),
        chatUsersDetail: chatRoomModel.chatUsersDetail,
        isReqAccepted: true,
        isLastMessageSeen: false,
        lastMsgSender: "-1");

    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(newChatRoom.chatRoomId)
        .set(newChatRoom.toJson());
  }
}
