import 'package:file_picker/file_picker.dart';
import 'package:vartalap/models/media.dart';
import 'package:vartalap/models/message.dart';
import 'package:flutter/material.dart';
import 'package:vartalap/utils/dateTimeFormat.dart';
import 'package:vartalap/widgets/rich_message.dart';

class MessageWidget extends StatelessWidget {
  final Message _msg;
  final bool _isYou;

  final bool isSelected;
  final Function onTab;
  final Function onLongPress;

  final TextStyle textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  MessageWidget(this._msg, this._isYou,
      {Key key, this.isSelected: false, this.onTab, this.onLongPress})
      : super(key: Key(_msg.id));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (this.onTab != null) {
            this.onTab(this._msg);
          }
        },
        onLongPress: () {
          if (this.onLongPress != null) {
            this.onLongPress(this._msg);
          }
        },
        child: Container(
          color: this.isSelected ? Colors.lightBlue[200] : Colors.transparent,
          constraints: BoxConstraints(
            minWidth: double.infinity,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                _isYou ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.grey[300],
                      offset: new Offset(1.0, 1.0),
                      blurRadius: 0.5,
                    )
                  ],
                  color: _isYou ? Colors.lightBlueAccent[100] : Colors.white38,
                  borderRadius: _isYou
                      ? BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                        )
                      : BorderRadius.only(
                          topRight: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                ),
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.25,
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _getMediaMessage(context),
                    _buildTextMessage(context),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          formatMessageDateTime(this._msg.timestamp),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11.0,
                          ),
                        ),
                        SizedBox(
                          width: 4.0,
                        ),
                        _isYou ? _getIcon() : Container()
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Container _buildTextMessage(BuildContext context) {
    return this._msg.text.isNotEmpty
        ? Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.25,
            ),
            child: RichMessage(
              (this._msg.text ?? ''),
              textStyle,
            ),
          )
        : Container();
  }

  Widget buildSingleMediaMessage(Media file) {
    if (file.type == FileType.image) {
      if (file.path.isNotEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          height: 210,
          child: Column(
            children: [
              Image.file(
                file.file,
                fit: BoxFit.fill,
                cacheHeight: 200,
                cacheWidth: 400,
                height: 200,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        );
      } else {
        Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          height: 250,
          child: Column(
            children: [
              Image.asset(
                'assets/images/blur.jpg',
                fit: BoxFit.fill,
                cacheHeight: 200,
                cacheWidth: 400,
                height: 200,
                filterQuality: FilterQuality.medium,
              )
            ],
          ),
        );
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.lightBlue[400],
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.file_present,
            color: Colors.white,
            size: 30,
          ),
          Flexible(
            child: Text(
              file.path.split('/').last,
              overflow: TextOverflow.clip,
              maxLines: 2,
            ),
          ),
          IconButton(icon: _getFileOperationIcon(file), onPressed: null)
        ],
      ),
    );
  }

  Widget buildMediaMessage() {
    if (this._msg.files.length == 1) {
      return buildSingleMediaMessage(this._msg.files[0]);
    } else {
      return Container(
        child: Column(
          children: this
              ._msg
              .files
              .map(
                (e) => buildSingleMediaMessage(e),
              )
              .toList(),
        ),
      );
    }
  }

  Widget _getMediaMessage(BuildContext context) {
    if (this._msg.files != null && this._msg.files.length > 0) {
      return buildMediaMessage();
    }
    return Container();
  }

  Widget _getFileOperationIcon(Media file) {
    var status = file.status;
    IconData icon;
    switch (status) {
      case MediaStatus.UPLOADED:
        if (!_isYou) icon = Icons.cloud_download;
        break;
      case MediaStatus.DOWNLOADED:
        break;
      case MediaStatus.UPLOAD_PENDING:
        if (_isYou) icon = Icons.cloud_upload;
        break;
      case MediaStatus.DOWNLOAD_FAILED:
        if (!_isYou) icon = Icons.cloud_download;
        break;
      case MediaStatus.UPLOAD_FAILED:
        if (_isYou) icon = Icons.cloud_upload;
        break;
      default:
    }
    return icon == null
        ? null
        : Icon(
            icon,
            color: Colors.white,
          );
  }

  Widget _getIcon() {
    IconData icon = Icons.access_time;
    Color color = Colors.white;
    switch (this._msg.state) {
      case MessageState.NEW:
        icon = Icons.access_time;
        break;
      case MessageState.SENT:
        icon = Icons.check;
        break;
      case MessageState.DELIVERED:
        icon = Icons.done_all;
        color = Colors.blueAccent;
    }

    return Icon(
      icon,
      size: 15.0,
      color: color,
    );
  }
}
