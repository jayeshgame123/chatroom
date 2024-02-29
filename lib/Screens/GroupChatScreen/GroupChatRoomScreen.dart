import 'dart:io';

import 'package:chat_app/Constants/Constants.dart';
import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/GroupChatRoom.dart';
import 'package:chat_app/Models/Helper/FirebaseHelper.dart';
import 'package:chat_app/Models/MessageModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/ReplyProvider.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:chat_app/Screens/GroupChatScreen/GroupDetailScreen.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:widget_zoom/widget_zoom.dart';

class GroupChatRoomScreen extends StatefulWidget {
  // final ChatUserModel? targetUser;
  final GroupChatRoomModel groupChatRoomModel;
  final UserModel userModel;
  final User firebaseUser;

  const GroupChatRoomScreen(
      {super.key,
      // required this.targetUser,
      required this.groupChatRoomModel,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<GroupChatRoomScreen> createState() => _GroupChatRoomScreenState();
}

class _GroupChatRoomScreenState extends State<GroupChatRoomScreen> {
  TextEditingController messageController = TextEditingController();
  UserModel? tagetedUserModel;
  File? imageFile;
  final focusNode = FocusNode();
  List<MessageModel> messageList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // messageSeen();
    // getTargetUserDetails();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    updateUserData();
    super.dispose();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 10),
          Expanded(
              // margin: const EdgeInsets.only(left: 7),
              child: Text(
            "Please wait while sending file.",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
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

  void sendMessage(String replyMsg, String replyImg, String replyMsgOf) async {
    String msg = messageController.text.trim();
    bool isNewDayMsg = false;
    messageController.clear();
    if (msg != "") {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoomModel.chatRoomId)
          .collection("messages")
          .orderBy("createdOn", descending: true)
          .get();
      if (snapshot.docs.isNotEmpty) {
        MessageModel lastMsg = MessageModel.fromJson(
            snapshot.docs[0].data() as Map<String, dynamic>);

        String lastDateTime =
            DateFormat('MM/dd/yyyy').format(lastMsg.createdOn!);
        String currDateTime = DateFormat('MM/dd/yyyy').format(DateTime.now());
        final DateFormat formatter = DateFormat('MM/dd/yyyy');

        DateTime currentDateTime = formatter.parse(currDateTime);
        DateTime lastMsgDateTime = formatter.parse(lastDateTime);

        Duration diff = currentDateTime.difference(lastMsgDateTime);

        if (diff.inDays >= 1) {
          isNewDayMsg = true;
        }
      }

      if (snapshot.docs.isEmpty) {
        isNewDayMsg = true;
      }

      MessageModel newMsg = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          text: msg,
          img: "",
          newDayFirstMsg: isNewDayMsg,
          seen: true,
          replyMsg: replyMsg,
          replyImg: replyImg,
          replyMsgOf: replyMsgOf,
          createdOn: DateTime.now());

      await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoomModel.chatRoomId)
          .collection("messages")
          .doc(newMsg.messageId)
          .set(newMsg.toJson());

      // tagetedUserModel =
      //     await FirebaseHelper.getUserModelById(widget.targetUser!.uid!);

      bool isMsgSeen = true;
      // if (tagetedUserModel != null) {
      //   if (tagetedUserModel!.isInChatRoom == true) {
      //     if (tagetedUserModel!.currentlyActiveChatRoomID ==
      //         widget.groupChatRoomModel.chatRoomId) {
      //       isMsgSeen = true;
      //     }
      //   }
      // }

      widget.groupChatRoomModel.lastMessage = msg;
      widget.groupChatRoomModel.isLastMessageSeen = isMsgSeen;
      widget.groupChatRoomModel.lastMsgSender = widget.userModel.uid;
      widget.groupChatRoomModel.updatedOn = DateTime.now();

      await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoomModel.chatRoomId)
          .set(widget.groupChatRoomModel.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final replyProvider = Provider.of<ReplyProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          title: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupDetailScreen(
                          groupChatRoomModel: widget.groupChatRoomModel,
                          userModel: widget.userModel,
                          firebaseUser: widget.firebaseUser)));
            },
            leading: CircleAvatar(
              radius: 20,
              backgroundImage:
                  NetworkImage(widget.groupChatRoomModel.groupPic!),
            ),
            title: Text(
              widget.groupChatRoomModel.groupName!,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            subtitle: const Text(
              "tap here for group info",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          )),
      body: SafeArea(
          child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("groupchatrooms")
                      .doc(widget.groupChatRoomModel.chatRoomId)
                      .collection("messages")
                      .orderBy("createdOn", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        messageList = [];
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          MessageModel currentMsg = MessageModel.fromJson(
                              snapshot.data!.docs[i].data());
                          messageList.add(currentMsg);
                        }
                        return ListView.builder(
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMsg = MessageModel.fromJson(
                                snapshot.data!.docs[index].data());

                            int indexI = 0;
                            if (currentMsg.sender != widget.userModel.uid) {
                              for (int i = 0;
                                  i <
                                      widget.groupChatRoomModel
                                          .groupChatUsersDetail!.length;
                                  i++) {
                                if (currentMsg.sender ==
                                    widget.groupChatRoomModel
                                        .groupChatUsersDetail!
                                        .elementAt(i)
                                        .uid) {
                                  indexI = i;
                                  break;
                                }
                              }
                            }

                            String formattedDate = DateFormat('hh:mm a')
                                .format(currentMsg.createdOn!);

                            String formattedNewMsgDate = "";
                            if (currentMsg.newDayFirstMsg!) {
                              String msgDateTime = DateFormat('MM/dd/yyyy')
                                  .format(currentMsg.createdOn!);
                              String currDateTime = DateFormat('MM/dd/yyyy')
                                  .format(DateTime.now());
                              final DateFormat formatter =
                                  DateFormat('MM/dd/yyyy');

                              DateTime currentDateTime =
                                  formatter.parse(currDateTime);
                              DateTime lastMsgDateTime =
                                  formatter.parse(msgDateTime);

                              Duration diff =
                                  currentDateTime.difference(lastMsgDateTime);
                              if (diff.inDays == 0) {
                                formattedNewMsgDate = "Today";
                              } else if (diff.inDays < 2) {
                                formattedNewMsgDate = "Yesterday";
                              } else {
                                formattedNewMsgDate = DateFormat('MM/dd/yyyy')
                                    .format(currentMsg.createdOn!);
                              }
                            }

                            String? senderName = "";
                            senderName = widget
                                .groupChatRoomModel.groupChatUsersDetail!
                                .elementAt(indexI)
                                .fullName;

                            return Column(
                              children: [
                                currentMsg.newDayFirstMsg!
                                    ? Center(
                                        child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(formattedNewMsgDate),
                                      ))
                                    : Container(),
                                currentMsg.sender == widget.userModel.uid
                                    ? SwipeTo(
                                        onRightSwipe: () {
                                          focusNode.requestFocus();
                                          replyProvider.setGroupReply(
                                              messageList[index],
                                              widget.groupChatRoomModel);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            currentMsg.replyMsg!.isNotEmpty
                                                ? Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 70,
                                                                  right: 5),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration: BoxDecoration(
                                                              color: themeProvider
                                                                          .themeMode ==
                                                                      ThemeMode
                                                                          .light
                                                                  ? Constants
                                                                      .meChatColor
                                                                  : Constants
                                                                      .darkMeChatColor,
                                                              borderRadius: const BorderRadius
                                                                      .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10))),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 3),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black12
                                                                        .withOpacity(
                                                                            0.07),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            7)),
                                                                child: Column(
                                                                  children: [
                                                                    // const SizedBox(
                                                                    //     height:
                                                                    //         8),
                                                                    IntrinsicHeight(
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Container(
                                                                            color:
                                                                                Colors.blue,
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          Flexible(
                                                                              child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const SizedBox(height: 5),
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      currentMsg.replyMsgOf!,
                                                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 10),
                                                                                  // GestureDetector(
                                                                                  //   onTap: () {
                                                                                  //     value.cancelReply();
                                                                                  //   },
                                                                                  //   child:
                                                                                  //       const Icon(Icons.close, size: 16),
                                                                                  // )
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 8),
                                                                              Container(
                                                                                margin: EdgeInsets.only(right: 5),
                                                                                child: Text(
                                                                                  currentMsg.replyMsg!,
                                                                                  style: TextStyle(
                                                                                    color: themeProvider.themeMode == ThemeMode.light ? Colors.black54 : Colors.white60,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 3),
                                                                            ],
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            3),
                                                                child: Text(
                                                                  currentMsg
                                                                      .text
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: themeProvider.themeMode ==
                                                                            ThemeMode
                                                                                .light
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .white,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 10,
                                                                  left: 0,
                                                                  top: 3,
                                                                  bottom: 7),
                                                          child: Text(
                                                            formattedDate,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        11),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : currentMsg.replyImg!
                                                        .isNotEmpty // for Images
                                                    ? Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 70,
                                                                      right: 5),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration: BoxDecoration(
                                                                  color: themeProvider
                                                                              .themeMode ==
                                                                          ThemeMode
                                                                              .light
                                                                      ? Constants
                                                                          .meChatColor
                                                                      : Constants
                                                                          .darkMeChatColor,
                                                                  borderRadius: const BorderRadius
                                                                          .only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10))),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        top: 3),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black12
                                                                            .withOpacity(
                                                                                0.07),
                                                                        borderRadius:
                                                                            BorderRadius.circular(7)),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        // const SizedBox(
                                                                        //     height:
                                                                        //         8),
                                                                        IntrinsicHeight(
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Container(
                                                                                color: Colors.blue,
                                                                                width: 4,
                                                                              ),
                                                                              const SizedBox(width: 8),
                                                                              Flexible(
                                                                                  child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const SizedBox(height: 5),
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Flexible(
                                                                                        child: Text(
                                                                                          currentMsg.replyMsgOf!,
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 10),
                                                                                      // GestureDetector(
                                                                                      //   onTap: () {
                                                                                      //     value.cancelReply();
                                                                                      //   },
                                                                                      //   child:
                                                                                      //       const Icon(Icons.close, size: 16),
                                                                                      // )
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(height: 8),
                                                                                  Container(
                                                                                    constraints: const BoxConstraints(maxHeight: 50),
                                                                                    // margin: const EdgeInsets.only(left: 3),
                                                                                    child: Image.network(currentMsg.replyImg!),
                                                                                  ),
                                                                                  const SizedBox(height: 3),
                                                                                ],
                                                                              )),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            3),
                                                                    child: Text(
                                                                      currentMsg
                                                                          .text
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color: themeProvider.themeMode == ThemeMode.light
                                                                              ? Colors.black
                                                                              : Colors.white),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 10,
                                                                      left: 0,
                                                                      top: 3,
                                                                      bottom:
                                                                          7),
                                                              child: Text(
                                                                formattedDate,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            11),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                                margin: const EdgeInsets
                                                                        .only(
                                                                    left: 70,
                                                                    right: 2,
                                                                    top: 5,
                                                                    bottom: 3),
                                                                padding: currentMsg
                                                                            .img ==
                                                                        ""
                                                                    ? const EdgeInsets.only(
                                                                        left:
                                                                            15,
                                                                        right:
                                                                            15,
                                                                        top: 10,
                                                                        bottom:
                                                                            10)
                                                                    : const EdgeInsets
                                                                            .only(
                                                                        left: 0,
                                                                        right:
                                                                            0,
                                                                        top: 0,
                                                                        bottom:
                                                                            0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: themeProvider.themeMode == ThemeMode.light
                                                                            ? Constants
                                                                                .meChatColor
                                                                            : Constants
                                                                                .darkMeChatColor,
                                                                        border: currentMsg.img ==
                                                                                ""
                                                                            ? const Border()
                                                                            : Border
                                                                                .all(
                                                                                width: 3,
                                                                                color: themeProvider.themeMode == ThemeMode.light ? Constants.meChatColor : Constants.darkMeChatColor,
                                                                              ),
                                                                        borderRadius: currentMsg.img ==
                                                                                ""
                                                                            ? BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                                                                            : BorderRadius.circular(5)),
                                                                child: currentMsg.img == ""
                                                                    ? Text(
                                                                        currentMsg
                                                                            .text
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18),
                                                                      )
                                                                    : WidgetZoom(
                                                                        heroAnimationTag:
                                                                            'tag',
                                                                        zoomWidget:
                                                                            Container(
                                                                          constraints:
                                                                              const BoxConstraints(
                                                                            maxHeight:
                                                                                200, //minimum height
                                                                            // maxWidth: 100,
                                                                          ),
                                                                          // height: 100,
                                                                          // width: 60,
                                                                          child:
                                                                              Image.network(currentMsg.img!),
                                                                        ),
                                                                      )),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 10,
                                                                      left: 0,
                                                                      top: 0,
                                                                      bottom:
                                                                          7),
                                                              child: Text(
                                                                formattedDate,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            11),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                            const SizedBox(width: 5),
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundImage: NetworkImage(
                                                  widget.userModel.profilePic!),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SwipeTo(
                                        onRightSwipe: () {
                                          replyProvider.setGroupReply(
                                              messageList[index],
                                              widget.groupChatRoomModel);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundImage: NetworkImage(
                                                  widget.groupChatRoomModel
                                                      .groupChatUsersDetail!
                                                      .elementAt(indexI)
                                                      .profilePic!),
                                            ),
                                            const SizedBox(width: 5),
                                            currentMsg.replyMsg!.isNotEmpty
                                                ? Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5,
                                                                  right: 70),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration: BoxDecoration(
                                                              color: themeProvider
                                                                          .themeMode ==
                                                                      ThemeMode
                                                                          .light
                                                                  ? Constants
                                                                      .youChatColor
                                                                  : Constants
                                                                      .darkYouChatColor,
                                                              borderRadius: BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10))),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(senderName!,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white)),
                                                              const SizedBox(
                                                                  height: 5),
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 3),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black12
                                                                        .withOpacity(
                                                                            0.07),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            7)),
                                                                child: Column(
                                                                  children: [
                                                                    // const SizedBox(
                                                                    //     height:
                                                                    //         8),
                                                                    IntrinsicHeight(
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Container(
                                                                            color:
                                                                                HexColor("#D3D3D3"),
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          Flexible(
                                                                              child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const SizedBox(height: 5),
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      currentMsg.replyMsgOf!,
                                                                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 10),
                                                                                  // GestureDetector(
                                                                                  //   onTap: () {
                                                                                  //     value.cancelReply();
                                                                                  //   },
                                                                                  //   child:
                                                                                  //       const Icon(Icons.close, size: 16),
                                                                                  // )
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 8),
                                                                              Container(
                                                                                margin: EdgeInsets.only(right: 5),
                                                                                child: Text(
                                                                                  currentMsg.replyMsg!,
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white54,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 3),
                                                                            ],
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            3),
                                                                child: Text(
                                                                  currentMsg
                                                                      .text
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 0,
                                                                  left: 10,
                                                                  top: 3,
                                                                  bottom: 7),
                                                          child: Text(
                                                            formattedDate,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        11),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : currentMsg.replyImg!
                                                        .isNotEmpty // for Images
                                                    ? Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 5,
                                                                      right:
                                                                          70),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration: BoxDecoration(
                                                                  color: themeProvider
                                                                              .themeMode ==
                                                                          ThemeMode
                                                                              .light
                                                                      ? Constants
                                                                          .youChatColor
                                                                      : Constants
                                                                          .darkYouChatColor,
                                                                  borderRadius: const BorderRadius
                                                                          .only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10))),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    child: Text(
                                                                        senderName!,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.white)),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        top: 3),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black12
                                                                            .withOpacity(
                                                                                0.07),
                                                                        borderRadius:
                                                                            BorderRadius.circular(7)),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        // const SizedBox(
                                                                        //     height:
                                                                        //         8),
                                                                        IntrinsicHeight(
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Container(
                                                                                color: HexColor("#D3D3D3"),
                                                                                width: 4,
                                                                              ),
                                                                              const SizedBox(width: 8),
                                                                              Flexible(
                                                                                  child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const SizedBox(height: 5),
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Flexible(
                                                                                        child: Text(
                                                                                          currentMsg.replyMsgOf!,
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 10),
                                                                                      // GestureDetector(
                                                                                      //   onTap: () {
                                                                                      //     value.cancelReply();
                                                                                      //   },
                                                                                      //   child:
                                                                                      //       const Icon(Icons.close, size: 16),
                                                                                      // )
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(height: 8),
                                                                                  Container(
                                                                                    constraints: const BoxConstraints(maxHeight: 50),
                                                                                    // margin: const EdgeInsets.only(left: 3),
                                                                                    child: Image.network(currentMsg.replyImg!),
                                                                                  ),
                                                                                  const SizedBox(height: 3),
                                                                                ],
                                                                              )),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            3),
                                                                    child: Text(
                                                                      currentMsg
                                                                          .text
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 0,
                                                                      left: 10,
                                                                      top: 3,
                                                                      bottom:
                                                                          7),
                                                              child: Text(
                                                                formattedDate,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            11),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 70,
                                                                      left: 2,
                                                                      top: 5,
                                                                      bottom:
                                                                          3),
                                                              padding: currentMsg
                                                                          .img ==
                                                                      ""
                                                                  ? const EdgeInsets
                                                                          .only(
                                                                      left: 15,
                                                                      right: 15,
                                                                      top: 10,
                                                                      bottom:
                                                                          10)
                                                                  : const EdgeInsets
                                                                          .only(
                                                                      left: 0,
                                                                      right: 0,
                                                                      top: 0,
                                                                      bottom:
                                                                          0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: themeProvider.themeMode ==
                                                                              ThemeMode
                                                                                  .light
                                                                          ? Constants
                                                                              .youChatColor
                                                                          : Constants
                                                                              .darkYouChatColor,
                                                                      border: currentMsg.img ==
                                                                              ""
                                                                          ? const Border()
                                                                          : Border
                                                                              .all(
                                                                              width: 3,
                                                                              color: themeProvider.themeMode == ThemeMode.light ? Constants.youChatColor : Constants.darkYouChatColor,
                                                                            ),
                                                                      borderRadius: currentMsg.text !=
                                                                              ""
                                                                          ? const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10),
                                                                              topRight: Radius.circular(10),
                                                                              bottomRight: Radius.circular(10))
                                                                          : BorderRadius.circular(5)),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    padding: currentMsg.img !=
                                                                            ""
                                                                        ? const EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                5,
                                                                            bottom:
                                                                                5)
                                                                        : const EdgeInsets.only(
                                                                            left:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            top:
                                                                                0,
                                                                            bottom:
                                                                                0),
                                                                    child: Text(
                                                                        senderName!,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.white)),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  currentMsg.img ==
                                                                          ""
                                                                      ? Text(
                                                                          currentMsg
                                                                              .text
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.white))
                                                                      : WidgetZoom(
                                                                          heroAnimationTag:
                                                                              'tag',
                                                                          zoomWidget:
                                                                              Container(
                                                                            constraints:
                                                                                const BoxConstraints(
                                                                              maxHeight: 200, //minimum height
                                                                              // maxWidth: 100,
                                                                            ),
                                                                            // height: 100,
                                                                            // width: 60,
                                                                            child:
                                                                                Image.network(currentMsg.img!),
                                                                          ),
                                                                        ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 0,
                                                                      left: 10,
                                                                      top: 0,
                                                                      bottom:
                                                                          7),
                                                              child: Text(
                                                                formattedDate,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                          ],
                                        ),
                                      ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("Something went wrong!"),
                        );
                      } else {
                        return const Center(
                          child: Text("Say hello!"),
                        );
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )),
              Column(
                children: [
                  Consumer<ReplyProvider>(builder: (context, value, child) {
                    //   replyProvider.isReplying
                    // ?
                    if (value.isReplying) {
                      return Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: themeProvider.themeMode == ThemeMode.light
                                ? Colors.grey.shade300
                                : Colors.black54,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                color: Colors.blue,
                                width: 4,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          value.replyMsgOf,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          value.cancelReply();
                                        },
                                        child:
                                            const Icon(Icons.close, size: 16),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  value.replyMsg != ""
                                      ? Text(
                                          value.replyMsg,
                                          style: TextStyle(
                                              color: themeProvider.themeMode ==
                                                      ThemeMode.light
                                                  ? Colors.black54
                                                  : Colors.white54),
                                        )
                                      : Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 70, //minimum height
                                            // maxWidth: 100,
                                          ),
                                          child: Image.network(value.replyImg))
                                ],
                              )),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
                  Consumer<ReplyProvider>(builder: (context, value, child) {
                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: 7, left: 5, right: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          color: themeProvider.themeMode == ThemeMode.light
                              ? Colors.grey.shade300
                              : Colors.black54,
                          borderRadius: value.isReplying
                              ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(35),
                                  bottomRight: Radius.circular(35))
                              : BorderRadius.circular(50)),
                      child: Row(
                        children: [
                          Flexible(
                              child: TextField(
                            controller: messageController,
                            focusNode: focusNode,
                            onTap: () {
                              Slidable.of(context)!.actionPaneType.dispose();
                            },
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                                color:
                                    themeProvider.themeMode == ThemeMode.light
                                        ? Colors.black
                                        : Colors.white),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter message",
                                hintStyle: TextStyle(
                                    color: themeProvider.themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white)),
                          )),
                          IconButton(
                              onPressed: () {
                                selectImage(ImageSource.gallery);
                              },
                              icon: Icon(Icons.attach_file,
                                  color:
                                      themeProvider.themeMode == ThemeMode.light
                                          ? Colors.black
                                          : Colors.white)),
                          const SizedBox(width: 10),
                          IconButton(
                              onPressed: () {
                                sendMessage(value.replyMsg, value.replyImg,
                                    value.replyMsgOf);
                                value.cancelReply();
                              },
                              icon: Icon(Icons.send,
                                  color:
                                      themeProvider.themeMode == ThemeMode.light
                                          ? Colors.black
                                          : Colors.white))
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          // StreamBuilder(
          //     stream: FirebaseFirestore.instance
          //         .collection("user")
          //         .where("uid", isEqualTo: widget.targetUser!.uid)
          //         .snapshots(),
          //     builder: (context, userData) {
          //       if (userData.connectionState == ConnectionState.active) {
          //         if (userData.hasData) {
          //           UserModel targetUser =
          //               UserModel.fromJson(userData.data!.docs[0].data());
          //           return Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               AnimatedContainer(
          //                 // Use the properties stored in the State class.
          //                 width: targetUser.isInChatRoom! ? 100 : 0,
          //                 height: targetUser.isInChatRoom! ? 40 : 0,
          //                 decoration: BoxDecoration(
          //                   color: Colors.blue,
          //                   borderRadius: BorderRadius.circular(50),
          //                 ),
          //                 // Define how long the animation should take.
          //                 duration: const Duration(seconds: 1),
          //                 // Provide an optional curve to make the animation feel smoother.
          //                 curve: Curves.fastOutSlowIn,
          //                 child: targetUser.isInChatRoom!
          //                     ? const Center(
          //                         child: Text("Active",
          //                             style: TextStyle(color: Colors.white)))
          //                     : const Text(""),
          //               ),
          //             ],
          //           );
          //           // Text("${targetUser.isInChatRoom}");
          //         } else {
          //           return Text("");
          //         }
          //       } else {
          //         return Text("");
          //       }
          //     })
        ],
      )),
    );
  }

  void messageSeen() async {
    // QuerySnapshot msgDataFromStore = await FirebaseFirestore.instance
    //     .collection("chatrooms")
    //     .doc(widget.chatRoomModel.chatRoomId)
    //     .collection("messages")
    //     .where("seen", isEqualTo: false).where("sender",isEqualTo: widget.targetUser!.uid)
    //     .get();

    // for (int i = 0; i < msgDataFromStore.docs.length; i++) {
    //   var exitingMsgData = await FirebaseFirestore.instance
    //       .collection("chatrooms")
    //       .doc(widget.chatRoomModel.chatRoomId)
    //       .collection("messages")
    //       .doc(msgDataFromStore.docs[i].id)
    //       .get();

    //   var data = MessageModel.fromJson(exitingMsgData.data() as Map<String, dynamic>);
    // MessageModel messageModel = MessageModel(
    //     messageId: data.messageId,
    //     sender: data.sender,
    //     text: data.text,
    //     seen: true,
    //     createdOn: data.createdOn);

    // await FirebaseFirestore.instance
    //     .collection("chatrooms")
    //     .doc(widget.chatRoomModel.chatRoomId)
    //     .collection("messages")
    //     .doc(messageModel.messageId)
    //     .set(messageModel.toJson());
    // }
    if (widget.groupChatRoomModel.lastMsgSender != widget.userModel.uid) {
      widget.groupChatRoomModel.isLastMessageSeen = true;

      await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoomModel.chatRoomId)
          .set(widget.groupChatRoomModel.toJson());
    }

    widget.userModel.currentlyActiveChatRoomID =
        widget.groupChatRoomModel.chatRoomId;
    widget.userModel.isInChatRoom = true;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.userModel.uid)
        .update(widget.userModel.toJson());

    // for (int i = 0; i < widget.chatRoomModel.chatUsersDetail!.length; i++) {
    //   if (widget.userModel.uid ==
    //       widget.chatRoomModel.chatUsersDetail!.elementAt(i).uid) {
    //     widget.chatRoomModel.chatUsersDetail!
    //         .elementAt(i)
    //         .currentlyActiveChatRoomID = widget.chatRoomModel.chatRoomId;
    //     widget.chatRoomModel.chatUsersDetail!.elementAt(i).isInChatRoom = true;
    //     break;
    //   }
    // }

    // await FirebaseFirestore.instance
    //     .collection("chatrooms")
    //     .doc(widget.chatRoomModel.chatRoomId)
    //     .update(widget.chatRoomModel.toJson());
  }

  void updateUserData() async {
    widget.userModel.currentlyActiveChatRoomID = "";
    widget.userModel.isInChatRoom = false;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.userModel.uid)
        .update(widget.userModel.toJson());
  }

  void getTargetUserDetails() async {
    // tagetedUserModel =
    //     await FirebaseHelper.getUserModelById(widget.targetUser!.uid!);
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
      imageFile = croppedFile;
      await sendImage();
    }
  }

  sendImage() async {
    showLoaderDialog(context);
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("chatimages")
        .child(widget.groupChatRoomModel.chatRoomId!)
        .child(uuid.v1())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    bool isNewDayMsg = false;
    QuerySnapshot snapshotData = await FirebaseFirestore.instance
        .collection("groupchatrooms")
        .doc(widget.groupChatRoomModel.chatRoomId)
        .collection("messages")
        .orderBy("createdOn", descending: true)
        .get();
    if (snapshotData.docs.isNotEmpty) {
      MessageModel lastMsg = MessageModel.fromJson(
          snapshotData.docs[0].data() as Map<String, dynamic>);

      String lastDateTime = DateFormat('MM/dd/yyyy').format(lastMsg.createdOn!);
      String currDateTime = DateFormat('MM/dd/yyyy').format(DateTime.now());
      final DateFormat formatter = DateFormat('MM/dd/yyyy');

      DateTime currentDateTime = formatter.parse(currDateTime);
      DateTime lastMsgDateTime = formatter.parse(lastDateTime);

      Duration diff = currentDateTime.difference(lastMsgDateTime);

      if (diff.inDays >= 1) {
        isNewDayMsg = true;
      }
    }

    if (snapshotData.docs.isEmpty) {
      isNewDayMsg = true;
    }

    MessageModel newMsg = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        text: "",
        img: imageUrl,
        newDayFirstMsg: isNewDayMsg,
        seen: false,
        replyMsg: "",
        replyImg: "",
        createdOn: DateTime.now());

    await FirebaseFirestore.instance
        .collection("groupchatrooms")
        .doc(widget.groupChatRoomModel.chatRoomId)
        .collection("messages")
        .doc(newMsg.messageId)
        .set(newMsg.toJson());

    // tagetedUserModel =
    //     await FirebaseHelper.getUserModelById(widget.targetUser!.uid!);

    bool isMsgSeen = false;
    if (tagetedUserModel != null) {
      if (tagetedUserModel!.isInChatRoom == true) {
        if (tagetedUserModel!.currentlyActiveChatRoomID ==
            widget.groupChatRoomModel.chatRoomId) {
          isMsgSeen = true;
        }
      }
    }

    widget.groupChatRoomModel.lastMessage = "Photo";
    widget.groupChatRoomModel.isLastMessageSeen = isMsgSeen;
    widget.groupChatRoomModel.lastMsgSender = widget.userModel.uid;
    widget.groupChatRoomModel.updatedOn = DateTime.now();

    await FirebaseFirestore.instance
        .collection("groupchatrooms")
        .doc(widget.groupChatRoomModel.chatRoomId)
        .set(widget.groupChatRoomModel.toJson());

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}
