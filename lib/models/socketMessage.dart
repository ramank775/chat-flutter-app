import 'package:vartalap/models/chat.dart';
import 'package:vartalap/models/media.dart';
import 'package:vartalap/models/message.dart';
import 'package:vartalap/utils/enum_helper.dart';

class SocketMedia {
  String resourceId;
  int type;
  int status;
}

class SocketMessage {
  String msgId;
  String to;
  String from;
  MessageType type;
  String chatId;
  String text;
  List<String> fileIds;
  MessageState state;

  SocketMessage.fromChatMessage(Message msg, Chat chat) {
    this.msgId = msg.id;
    this.from = msg.senderId;
    this.type = msg.type;
    this.chatId = msg.chatId;
    this.text = msg.text;
    if (msg.files != null || msg.files.length > 0) {
      this.fileIds = msg.files.map((e) => e.resourceId).toList();
    }
    this.state = msg.state;
    this.to = chat.users
        .singleWhere((element) => element.username != msg.senderId)
        .username;
  }

  SocketMessage.fromMap(Map<String, dynamic> map) {
    this.msgId = map["msgId"];
    this.to = map["to"];
    this.from = map["from"];
    this.type = stringToEnum(map["type"], MessageType.values);
    this.text = map["text"];
    this.chatId = map["chatId"] != null ? map["chatId"] : this.from;
    this.fileIds = map["fileIds"];
    this.state = map["state"] != null
        ? stringToEnum(map["state"], MessageState.values)
        : MessageState.NEW;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "msgId": this.msgId,
      "to": this.to,
      "from": this.from,
      "type": enumToString(this.type),
      "chatId": this.chatId,
      "text": this.text,
      "fileIds": this.fileIds,
      "state": enumToString(this.state)
    };
    return map;
  }

  Message toMessage() {
    var files = (this.fileIds == null ? [] : this.fileIds)
        .map((e) =>
            Media(this.msgId, resourceId: e, status: MediaStatus.UPLOADED))
        .toList();
    Message msg = Message(
      this.msgId,
      this.chatId,
      this.from,
      this.text,
      MessageState.NEW,
      DateTime.now().millisecondsSinceEpoch,
      this.type,
      files,
    );

    return msg;
  }
}
