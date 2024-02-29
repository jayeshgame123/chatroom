class UserModel {
  String? uid;
  String? fullName;
  String? userName;
  String? email;
  String? profilePic;
  String? currentlyActiveChatRoomID;
  bool? isInChatRoom;
  String? status;
  DateTime? lastSeen;

  UserModel(
      {this.uid, this.fullName, this.userName, this.email, this.profilePic,this.currentlyActiveChatRoomID,this.isInChatRoom,this.status,this.lastSeen});

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    fullName = json['fullName'];
    userName = json['userName'];
    email = json['email'];
    profilePic = json['profilePic'];
    currentlyActiveChatRoomID = json['currentlyActiveChatRoomID'];
    isInChatRoom = json['isInChatRoom'];
    status = json['status'];
    lastSeen = json['lastSeen'].toDate();
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
    data['status'] = this.status;
    data['lastSeen'] = this.lastSeen;
    return data;
  }
}
