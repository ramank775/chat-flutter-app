import 'dart:async';
import 'dart:io';

import 'package:vartalap/dataAccessLayer/db.dart';
import 'package:vartalap/models/chat.dart';
import 'package:vartalap/models/media.dart';
import 'package:vartalap/models/message.dart';
import 'package:vartalap/services/api_service.dart';
import 'package:vartalap/utils/enum_helper.dart';

class FileUplaodMessge {
  Chat chat;
  Message message;
  FileUplaodMessge(this.chat, this.message);
}

class _FileUploadResponse {
  String resourceId;
  bool status;
  _FileUploadResponse(this.resourceId, this.status);
}

class FileUploadService {
  static FileUploadService _instance;

  Stream<FileUplaodMessge> onuploadComplete;

  StreamController<FileUplaodMessge> _uploadController =
      StreamController<FileUplaodMessge>();

  FileUploadService() {
    onuploadComplete =
        _uploadController.stream.asyncMap(uploadFiles).asBroadcastStream();
    onuploadComplete.listen((event) async {
      var msg = event.message;
      if (msg.files == null || msg.files.length <= 0) {
        return;
      }
      var db = await DB().getDb();
      var batch = db.batch();
      msg.files.forEach((element) {
        batch.update(
            "resources",
            {
              "status": enumToInt(element.status, MediaStatus.values),
            },
            where: "id=?",
            whereArgs: [element.id]);
      });
      await batch.commit();
    });
  }

  upload(Message msg, Chat chat) {
    var fmsg = FileUplaodMessge(chat, msg);
    _uploadController.sink.add(fmsg);
  }

  Future<FileUplaodMessge> uploadFiles(FileUplaodMessge incomming) async {
    var files = incomming.message.files;
    if (files == null || files.length == 0) {
      return incomming;
    }
    List<Future<_FileUploadResponse>> uploadFuture = [];
    files.forEach((media) {
      var future = uploadFile(media.file);
      uploadFuture.add(future);
    });
    var results = await Future.wait<_FileUploadResponse>(uploadFuture);
    for (var i = 0; i < results.length; i++) {
      files[i].status =
          results[i].status ? MediaStatus.UPLOADED : MediaStatus.UPLOAD_FAILED;
      files[i].resourceId = results[i].resourceId;
    }
    return incomming;
  }

  Future<_FileUploadResponse> uploadFile(File file) {
    return ApiService.getUploadUrl(file.path.split('/').last)
        .then((value) async {
      var url = value["url"];
      var resourceId = value["fileName"];
      var status = await ApiService.uploadFile(url, file);
      var resp = _FileUploadResponse(resourceId, status);
      return resp;
    }).catchError(() => _FileUploadResponse(null, false));
  }

  void dispose() {
    if (_uploadController != null) _uploadController.close();
  }

  static FileUploadService get instance {
    if (_instance == null) {
      _instance = FileUploadService();
    }
    return _instance;
  }
}
