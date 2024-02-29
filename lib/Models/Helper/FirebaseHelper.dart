import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;
    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("user").doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromJson(docSnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }

  static Future<List<ChatRoomModel?>> getChatRooms(UserModel userModel) async {
    List<ChatRoomModel>? chatRoomModel = [];
    QuerySnapshot snapshot = (await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("users", arrayContains: userModel.uid)
        .orderBy("updatedOn", descending: true)
        .get());
        
    for (int i = 0; i < snapshot.docs.length; i++) {
      var exitingChatRoomData = await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(snapshot.docs.elementAt(i).id)
          .get();
          chatRoomModel.add(ChatRoomModel.fromJson(exitingChatRoomData.data() as Map<String, dynamic>));
    }
    return chatRoomModel;
  }
}
