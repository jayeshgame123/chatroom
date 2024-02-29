class GroupChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? createdOn;
  DateTime? updatedOn;
  bool? isLastMessageSeen;
  String? lastMsgSender;
  List<GroupChatUserModel>? groupChatUsersDetail;
  String? groupName;
  String? groupPic;
  String? createdBy;

  GroupChatRoomModel(
      {this.chatRoomId,
      this.participants,
      this.lastMessage,
      this.users,
      this.createdOn,
      this.updatedOn,
      this.isLastMessageSeen,
      this.lastMsgSender,
      this.groupChatUsersDetail,
      this.groupName,
      this.groupPic,
      this.createdBy});

  GroupChatRoomModel.fromJson(Map<String, dynamic> json) {
    chatRoomId = json['chatRoomId'];
    participants = json['participants'].cast<String, dynamic>();
    lastMessage = json['lastMessage'];
    users = json['users'];
    createdOn = json['createdOn'].toDate();
    updatedOn = json['updatedOn'].toDate();
    isLastMessageSeen = json['isLastMessageSeen'];
    lastMsgSender = json['lastMsgSender'];
    // chatUsersDetail = json['chatUsersDetail'];
    if (json['groupChatUsersDetail'] != null) {
      groupChatUsersDetail = <GroupChatUserModel>[];
      json['groupChatUsersDetail'].forEach((v) {
        groupChatUsersDetail!.add(new GroupChatUserModel.fromJson(v));
      });
    }
    groupName = json['groupName'];
    groupPic = json['groupPic'];
    createdBy = json['createdBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatRoomId'] = this.chatRoomId;
    data['participants'] = this.participants;
    data['lastMessage'] = this.lastMessage;
    data['users'] = this.users;
    data['createdOn'] = this.createdOn;
    data['updatedOn'] = this.updatedOn;
    data['isLastMessageSeen'] = this.isLastMessageSeen;
    data['lastMsgSender'] = this.lastMsgSender;
    // data['chatUsersDetail'] = this.chatUsersDetail;
    if (this.groupChatUsersDetail != null) {
      data['groupChatUsersDetail'] =
          this.groupChatUsersDetail!.map((v) => v.toJson()).toList();
    }
    data['groupName'] = this.groupName;
    data['groupPic'] = this.groupPic;
    data['createdBy'] = this.createdBy;
    return data;
  }
}

class GroupChatUserModel {
  String? uid;
  String? fullName;
  String? userName;
  String? email;
  String? profilePic;
  String? currentlyActiveChatRoomID;
  bool? isInChatRoom;

  GroupChatUserModel(
      {this.uid,
      this.fullName,
      this.userName,
      this.email,
      this.profilePic,
      this.currentlyActiveChatRoomID,
      this.isInChatRoom});

  GroupChatUserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    fullName = json['fullName'];
    userName = json['userName'];
    email = json['email'];
    profilePic = json['profilePic'];
    currentlyActiveChatRoomID = json['currentlyActiveChatRoomID'];
    isInChatRoom = json['isInChatRoom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['fullName'] = this.fullName;
    data['userName'] = this.userName;
    data['email'] = this.email;
    data['profilePic'] = this.profilePic;
    data['currentlyActiveChatRoomID'] = this.currentlyActiveChatRoomID;
    data['isInChatRoom'] = this.isInChatRoom;
    return data;
  }
}
