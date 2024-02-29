import 'dart:developer';

import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/GroupChatRoom.dart';
import 'package:chat_app/Models/Helper/FirebaseHelper.dart';
import 'package:chat_app/Models/MessageModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/Provider.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:chat_app/Screens/ChatRoomScreen.dart';
import 'package:chat_app/Screens/GroupChatScreen/CreateGroupScreen.dart';
import 'package:chat_app/Screens/GroupChatScreen/GroupChatRoomScreen.dart';
import 'package:chat_app/Screens/LoginScreen.dart';
import 'package:chat_app/Screens/ProfileScreen.dart';
import 'package:chat_app/Screens/RequestScreen.dart';
import 'package:chat_app/Screens/SearchScreen.dart';
import 'package:chat_app/Screens/Settings/SettingScreen.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomeScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // int unseenMsgCount = 0;
  GroupChatRoomModel? groupChatRoomModel;
  TabController? tabController;
  bool isChecked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Constants.setStatus(widget.userModel, "online");
    updateUserData();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0)
      ..addListener(() {
        // setState(() {});
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      Constants.setStatus(widget.userModel, "online");
    } else {
      Constants.setStatus(widget.userModel, "offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (!isChecked) {
      checkIsDarkMode(themeProvider);
    }
    return Scaffold(
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 63,
                    backgroundColor: themeProvider.themeMode == ThemeMode.light
                        ? Colors.blue
                        : Colors.grey,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          NetworkImage(widget.userModel.profilePic!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${widget.userModel.fullName}",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${widget.userModel.userName}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 0.5,
                color: Colors.black,
                indent: 30,
                endIndent: 30,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.person),
                title: const Text('Profile',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser)))
                      .then((value) {
                    setState(() {});
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: const Text('Settings',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingScreen(
                              userModel: widget.userModel,
                              firebaseUser: widget.firebaseUser)));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Log out',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                onTap: () async {
                  Constants.setStatus(widget.userModel, "offline");
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        // centerTitle: true,
        // automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person)),
            Tab(icon: Icon(Icons.people)),
            // Tab(icon: Icon(Icons.directions_bike)),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Center(child: Text("Chat Room"))),
            StreamBuilder(
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
                        int reqCount = 0;
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromJson(
                              snapshot.data!.docs[i].data());
                          if (chatRoomModel.reqSender != widget.userModel.uid) {
                            reqCount++;
                          }
                        }

                        if (reqCount > 0) {
                          return badges.Badge(
                            position:
                                badges.BadgePosition.topEnd(top: 5, end: -2),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RequestScreen(
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser)));
                            },
                            badgeAnimation: const badges.BadgeAnimation.scale(
                              animationDuration: Duration(seconds: 1),
                              colorChangeAnimationDuration:
                                  Duration(seconds: 1),
                              loopAnimation: false,
                              curve: Curves.fastOutSlowIn,
                            ),
                            badgeStyle:
                                badges.BadgeStyle(badgeColor: Colors.white),
                            badgeContent: Text(
                              '${reqCount}',
                              style: TextStyle(color: Colors.black),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RequestScreen(
                                              userModel: widget.userModel,
                                              firebaseUser:
                                                  widget.firebaseUser)));
                                },
                                icon: const Icon(Icons.person_add)),
                          );
                        } else {
                          return IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RequestScreen(
                                            userModel: widget.userModel,
                                            firebaseUser:
                                                widget.firebaseUser)));
                              },
                              icon: const Icon(Icons.person_add));
                        }
                      } else {
                        return IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RequestScreen(
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser)));
                            },
                            icon: const Icon(Icons.person_add));
                      }
                    } else {
                      return IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RequestScreen(
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser)));
                          },
                          icon: const Icon(Icons.person_add));
                    }
                  } else {
                    return const Icon(Icons.person_add);
                  }
                })
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          SafeArea(
              child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .where("users", arrayContains: widget.userModel.uid)
                  .where("isReqAccepted", isEqualTo: true)
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

                          String formattedDate = "";
                          Duration diff = DateTime.now()
                              .difference(chatRoomModel.updatedOn!);
                          if (diff.inSeconds != null) {
                            if (diff.inSeconds < 60) {
                              formattedDate = "now";
                            } else if (diff.inMinutes < 60) {
                              formattedDate = "${diff.inMinutes} min";
                            } else {
                              String msgDateTime = DateFormat('MM/dd/yyyy')
                                  .format(chatRoomModel.updatedOn!);
                              String currDateTime = DateFormat('MM/dd/yyyy')
                                  .format(DateTime.now());
                              final DateFormat formatter =
                                  DateFormat('MM/dd/yyyy');

                              DateTime currentDateTime =
                                  formatter.parse(currDateTime);
                              DateTime lastMsgDateTime =
                                  formatter.parse(msgDateTime);

                              Duration diffOfDay =
                                  currentDateTime.difference(lastMsgDateTime);
                              if (diffOfDay.inDays == 0) {
                                formattedDate = DateFormat('hh:mm a')
                                    .format(chatRoomModel.updatedOn!);
                              } else if (diffOfDay.inDays < 2) {
                                formattedDate = "yesterday";
                              } else {
                                formattedDate = DateFormat('MM/dd/yy')
                                    .format(chatRoomModel.updatedOn!);
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatRoomScreen(
                                              targetUser: chatRoomModel
                                                  .chatUsersDetail![indexI],
                                              chatRoomModel: chatRoomModel,
                                              userModel: widget.userModel,
                                              firebaseUser:
                                                  widget.firebaseUser))).then(
                                      (value) {
                                    // print(chatRoomModel.chatUsersDetail![indexI].fullName
                                    //     .toString());
                                    // updateUserData(chatRoomModel, indexI);
                                    Constants.setStatus(
                                        widget.userModel, "online");
                                  });
                                },
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(chatRoomModel
                                      .chatUsersDetail![indexI].profilePic!),
                                ),
                                title: Text(
                                  chatRoomModel
                                      .chatUsersDetail![indexI].fullName
                                      .toString(),
                                  style: const TextStyle(fontSize: 19),
                                ),
                                subtitle: Text(
                                  chatRoomModel.lastMessage!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                trailing: Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      formattedDate,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 5),
                                    chatRoomModel.isLastMessageSeen!
                                        ? const SizedBox(
                                            width: 0,
                                            height: 0,
                                          )
                                        : chatRoomModel.lastMsgSender !=
                                                widget.userModel.uid
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 7, 114, 255),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                width: 10,
                                                height: 10,
                                              )
                                            : const SizedBox(
                                                width: 0,
                                                height: 0,
                                              ),
                                  ],
                                )),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("No chats"),
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

          //----------------------------------------------------------

          SafeArea(
              child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("groupchatrooms")
                  .where("users", arrayContains: widget.userModel.uid)
                  .orderBy("updatedOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          GroupChatRoomModel groupChatRoomModel =
                              GroupChatRoomModel.fromJson(
                                  snapshot.data!.docs[index].data());

                          String formattedDate = "";
                          Duration diff = DateTime.now()
                              .difference(groupChatRoomModel.updatedOn!);
                          if (diff.inSeconds != null) {
                            if (diff.inSeconds < 60) {
                              formattedDate = "now";
                            } else if (diff.inMinutes < 60) {
                              formattedDate = "${diff.inMinutes} min";
                            } else if (diff.inHours < 24) {
                              formattedDate = DateFormat('hh:mm a')
                                  .format(groupChatRoomModel.updatedOn!);
                            } else if (diff.inDays < 2) {
                              formattedDate = "yesterday";
                            } else {
                              formattedDate = DateFormat('MM/dd/yy')
                                  .format(groupChatRoomModel.updatedOn!);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GroupChatRoomScreen(
                                                  groupChatRoomModel:
                                                      groupChatRoomModel,
                                                  userModel: widget.userModel,
                                                  firebaseUser: widget
                                                      .firebaseUser))).then(
                                      (value) {});
                                },
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                      groupChatRoomModel.groupPic!),
                                ),
                                title: Text(
                                  groupChatRoomModel.groupName!,
                                  style: TextStyle(fontSize: 19),
                                ),
                                subtitle: Text(
                                  groupChatRoomModel.lastMessage!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                trailing: Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      "${formattedDate}",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 5),
                                    groupChatRoomModel.isLastMessageSeen!
                                        ? const SizedBox(
                                            width: 0,
                                            height: 0,
                                          )
                                        : groupChatRoomModel.lastMsgSender !=
                                                widget.userModel.uid
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 7, 114, 255),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                width: 10,
                                                height: 10,
                                              )
                                            : const SizedBox(
                                                width: 0,
                                                height: 0,
                                              ),
                                  ],
                                )),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("No group chats"),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchScreen(
                              userModel: widget.userModel,
                              firebaseUser: widget.firebaseUser)));
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateGroupScreen(
                              userModel: widget.userModel,
                              firebaseUser: widget.firebaseUser)));
                },
                icon: const Icon(Icons.add))
          ],
        ),
      ),
    );
  }

  Future<ChatRoomModel> messageSeen(
      ChatRoomModel chatRoomModel, ChatUserModel chatUser) async {
    QuerySnapshot msgDataFromStore = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("chatRoomId", isEqualTo: chatRoomModel.chatRoomId)
        // .where("isLastMessageSeen", isEqualTo: false).where("lastMsgSender",isEqualTo: chatUser.uid)
        .get();

    var exitingMsgData = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(msgDataFromStore.docs[0].id)
        .get();

    var data =
        ChatRoomModel.fromJson(exitingMsgData.data() as Map<String, dynamic>);
    print(data);
    var unseenMsgCount = "";
    // if (msgDataFromStore.docs.isNotEmpty) {
    //   print(msgDataFromStore.docs.length);
    //   unseenMsgCount = msgDataFromStore.docs.length.toString();
    // }
    return data;
  }

  void updateUserData() async {
    widget.userModel.currentlyActiveChatRoomID = "";
    widget.userModel.isInChatRoom = false;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.userModel.uid)
        .update(widget.userModel.toJson());

    // for (int i = 0; i < chatRoomModel.chatUsersDetail!.length; i++) {
    //   if (widget.userModel.uid ==
    //       chatRoomModel.chatUsersDetail!.elementAt(i).uid) {
    //     chatRoomModel.chatUsersDetail![i].currentlyActiveChatRoomID = "";
    //     chatRoomModel.chatUsersDetail![i].isInChatRoom = false;
    //     break;
    //   }
    // }

    // await FirebaseFirestore.instance
    //     .collection("chatrooms")
    //     .doc(chatRoomModel.chatRoomId)
    //     .update(chatRoomModel.toJson());
  }

  groupChatRoom() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("groupchatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .get();

    GroupChatUserModel userModel = GroupChatUserModel(
        email: widget.userModel.email,
        fullName: widget.userModel.fullName,
        profilePic: widget.userModel.profilePic,
        uid: widget.userModel.uid,
        userName: widget.userModel.userName,
        currentlyActiveChatRoomID: widget.userModel.currentlyActiveChatRoomID,
        isInChatRoom: widget.userModel.isInChatRoom);

    if (snapshot.docs.isNotEmpty) {
      log("chat room already exist");
      GroupChatRoomModel existingGroupChatRoom = GroupChatRoomModel.fromJson(
          snapshot.docs[0].data() as Map<String, dynamic>);
      groupChatRoomModel = existingGroupChatRoom;
    } else {
      GroupChatRoomModel newGroupChatRoom = GroupChatRoomModel(
          chatRoomId: uuid.v1(),
          participants: {
            widget.userModel.uid.toString(): true,
          },
          lastMessage: "",
          users: [widget.userModel.uid.toString()],
          createdOn: DateTime.now(),
          updatedOn: DateTime.now(),
          groupChatUsersDetail: [userModel]);

      await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(newGroupChatRoom.chatRoomId)
          .set(newGroupChatRoom.toJson());
      groupChatRoomModel = newGroupChatRoom;
      // log("chat room created");
    }
    return groupChatRoomModel;
  }

  void checkIsDarkMode(ThemeProvider themeProvider) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isDarkMode = pref.getBool("isDarkMode");

    if (isDarkMode != null) {
      if (isDarkMode) {
        themeProvider.setTheme(ThemeMode.dark);
      } else {
        themeProvider.setTheme(ThemeMode.light);
      }
    } else {
      themeProvider.setTheme(ThemeMode.light);
    }

    setState(() {
      isChecked = true;
    });
  }
}
