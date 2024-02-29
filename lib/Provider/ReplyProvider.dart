import 'package:flutter/material.dart';

class ReplyProvider with ChangeNotifier {
  bool _isReplying = false;
  String _replyMsg = "";
  String _replyImg = "";
  String _replyMsgOf = "";

  get isReplying => _isReplying;
  get replyMsg => _replyMsg;
  get replyImg => _replyImg;
  get replyMsgOf => _replyMsgOf;

  void setReply(currentMsg, userModel, targetUser) {
    if(currentMsg.text != ""){
    _replyMsg = currentMsg.text;
    }else{
      _replyImg = currentMsg.img;
    }
    if (currentMsg.sender! == userModel.uid) {
      _replyMsgOf = "${userModel.fullName}";
    } else {
      _replyMsgOf = "${targetUser!.fullName}";
    }
    _isReplying = true;
    notifyListeners();
  }

  void setGroupReply(currentMsg,groupChatRoomModel) {
    if(currentMsg.text != ""){
    _replyMsg = currentMsg.text;
    }else{
      _replyImg = currentMsg.img;
    }
    for(int i = 0; i < groupChatRoomModel.groupChatUsersDetail.length; i++){
      if (currentMsg.sender! == groupChatRoomModel.groupChatUsersDetail.elementAt(i).uid) {
      _replyMsgOf = "${groupChatRoomModel.groupChatUsersDetail.elementAt(i).fullName}";
      break;
    }
    }
    _isReplying = true;
    notifyListeners();
  }

  void cancelReply() {
    _replyMsg = "";
    _replyImg = "";
    _replyMsgOf = "";
    _isReplying = false;
    notifyListeners();
  }
}
