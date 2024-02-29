class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  String? img;
  bool? seen;
  bool? newDayFirstMsg;
  DateTime? createdOn;
  String? replyMsg;
  String? replyImg;
  String? replyMsgOf;

  MessageModel({this.messageId,this.sender, this.text, this.img,this.seen, this.newDayFirstMsg,this.createdOn,this.replyMsg,this.replyMsgOf,this.replyImg});

  MessageModel.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    sender = json['sender'];
    text = json['text'];
    img = json['img'];
    seen = json['seen'];
    newDayFirstMsg = json['newDayFirstMsg'];
    createdOn = json['createdOn'].toDate();
    replyMsg = json['replyMsg'];
    replyImg = json['replyImg'];
    replyMsgOf = json['replyMsgOf'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageId'] = this.messageId;
    data['sender'] = this.sender;
    data['text'] = this.text;
    data['img'] = this.img;
    data['seen'] = this.seen;
    data['newDayFirstMsg'] = this.newDayFirstMsg;
    data['createdOn'] = this.createdOn;
    data['replyMsg'] = this.replyMsg;
    data['replyImg'] = this.replyImg;
    data['replyMsgOf'] = this.replyMsgOf;
    return data;
  }
}
