import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

class RequestScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const RequestScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("users", arrayContains: widget.userModel.uid)
              .where("isReqAccepted", isEqualTo: false)
              .orderBy("updatedOn", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromJson(
                          snapshot.data!.docs[index].data());

                      int indexI = -1;
                      for (int i = 0;
                          i < chatRoomModel.chatUsersDetail!.length;
                          i++) {
                        if (widget.userModel.uid !=
                            chatRoomModel.chatUsersDetail![i].uid) {
                          indexI = i;
                          break;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: chatRoomModel.reqSender != widget.userModel.uid
                            ? ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(chatRoomModel
                                      .chatUsersDetail![indexI].profilePic!),
                                ),
                                title: Text(
                                  chatRoomModel
                                      .chatUsersDetail![indexI].fullName
                                      .toString(),
                                  style: TextStyle(fontSize: 19),
                                ),
                                subtitle: Text(chatRoomModel
                                    .chatUsersDetail![indexI].userName
                                    .toString()),
                                trailing: TextButton(
                                    onPressed: () {
                                      reqAccepted(chatRoomModel);
                                    },
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(
                                          color: themeProvider.themeMode ==
                                                  ThemeMode.light
                                              ? Colors.blue
                                              : Colors.white),
                                    )),
                              )
                            : ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(chatRoomModel
                                      .chatUsersDetail![indexI].profilePic!),
                                ),
                                title: Text(
                                  chatRoomModel
                                      .chatUsersDetail![indexI].fullName
                                      .toString(),
                                  style: TextStyle(fontSize: 19),
                                ),
                                subtitle: Text(chatRoomModel
                                    .chatUsersDetail![index].userName
                                    .toString()),
                                trailing: const Text("Sended",style: TextStyle(color: Colors.grey),)
                                ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("No new requests"),
                  );
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text(""),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
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
