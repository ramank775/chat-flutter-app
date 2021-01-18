import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:vartalap/utils/enum_helper.dart';

enum MediaStatus {
  UPLOAD_PENDING,
  UPLOADED,
  UPLOAD_FAILED,
  DOWNLOADED,
  DOWNLOAD_FAILED,
}

// id int PRIMARY KEY,
// resource_id TEXT,
// local_path TEXT,
// messageId TEXT NOT NULL,
// int status DEFAULT 0,

class Media {
  int id;
  File file;
  String messageId;
  String resourceId;
  String path;
  FileType type;
  MediaStatus status = MediaStatus.UPLOAD_PENDING;

  Media(
    this.messageId, {
    this.file,
    this.id,
    this.resourceId,
    this.path,
    this.type,
    this.status,
  });

  Media.fromMap(Map<String, dynamic> map) {
    this.resourceId = map["resource_id"];
    this.path = map["local_path"];
    this.messageId = map["messageId"];
    this.status = intToEnum(map["status"], MediaStatus.values);
    if (path != null) {
      this.file = File(path);
      this.type = intToEnum(map["type"], FileType.values);
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map["resource_id"] = this.resourceId;
    map["local_path"] = this.path;
    map["messageId"] = this.messageId;
    map["status"] = enumToInt(this.status, MediaStatus.values);
    map["type"] = enumToInt(this.type, FileType.values);
    return map;
  }
}
