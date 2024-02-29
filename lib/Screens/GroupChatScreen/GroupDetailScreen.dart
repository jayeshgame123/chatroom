import 'package:chat_app/Models/GroupChatRoom.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:chat_app/Screens/GroupChatScreen/AddGroupUserScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupChatRoomModel groupChatRoomModel;
  final UserModel userModel;
  final User firebaseUser;

  const GroupDetailScreen(
      {super.key,
      required this.groupChatRoomModel,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String createdOnDateTime =
        DateFormat('MM/dd/yyyy').format(widget.groupChatRoomModel.createdOn!);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 63,
                backgroundColor: themeProvider.themeMode == ThemeMode.light ? Colors.blue: Colors.grey,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      NetworkImage(widget.groupChatRoomModel.groupPic!),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                widget.groupChatRoomModel.groupName!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
             Text(
                "Group ${widget.groupChatRoomModel.users!.length} participants",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Created on: $createdOnDateTime",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      "${widget.groupChatRoomModel.users!.length} Participants",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    child: ListView.builder(
                        itemCount: widget
                            .groupChatRoomModel.groupChatUsersDetail!.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isAdmin = false;
                          if (widget.groupChatRoomModel.createdBy ==
                              widget.groupChatRoomModel.groupChatUsersDetail!
                                  .elementAt(index)
                                  .uid) {
                            isAdmin = true;
                          }
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(widget
                                  .groupChatRoomModel.groupChatUsersDetail!
                                  .elementAt(index)
                                  .profilePic!),
                            ),
                            title: Text(widget
                                .groupChatRoomModel.groupChatUsersDetail!
                                .elementAt(index)
                                .fullName
                                .toString()),
                            subtitle: Text(widget
                                .groupChatRoomModel.groupChatUsersDetail!
                                .elementAt(index)
                                .userName
                                .toString()),
                            trailing: isAdmin ? const Text("Group Admin") : const Text(""),
                          );
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              widget.userModel.uid == widget.groupChatRoomModel.createdBy
              ?ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddGroupUserScreen(
                              userModel: widget.userModel,
                              firebaseUser: widget.firebaseUser,
                              groupChatRoomModel: widget.groupChatRoomModel)));
                },
                leading: CircleAvatar(
                  backgroundColor: themeProvider.themeMode == ThemeMode.light ? Colors.blue: Colors.grey,
                  child: Icon(Icons.person_add_alt_1,color: themeProvider.themeMode == ThemeMode.light ? Colors.white: Colors.black,),
                ),
                title: const Text("Add members"),
              )
              :Container(),
            ],
          ),
        ),
      )),
    );
  }
}
