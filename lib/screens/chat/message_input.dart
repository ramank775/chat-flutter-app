import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vartalap/widgets/file_selection_item.dart';
import 'package:vartalap/widgets/sider_item.dart';

class MessageInputWidget extends StatefulWidget {
  final Function(String text, {List<File> files}) sendMessage;
  MessageInputWidget({Key key, this.sendMessage}) : super(key: key);

  @override
  MessageInputState createState() => MessageInputState();
}

class MessageInputState extends State<MessageInputWidget> {
  Function(String text, {List<File> files, FileType fileType}) _sendMessage;
  bool _isShowSticker;
  FocusNode _inputFocus;
  bool _isSlider;
  List<File> _files;
  FileType _fileType;

  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _sendMessage = widget.sendMessage;
    _isShowSticker = false;
    _isSlider = false;
    _inputFocus = FocusNode();
    _inputFocus.addListener(onFocusListener);
  }

  void dispose() {
    super.dispose();
    _inputFocus.removeListener(onFocusListener);
  }

  void onFocusListener() {
    if (_isShowSticker && _inputFocus.hasFocus) {
      setState(() {
        _isShowSticker = false;
      });
    }
  }

  Future<bool> onBackPress() {
    if (_isShowSticker) {
      setState(() {
        _isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _isSlider ? showConfirmationPreview() : Container(),
              buildInput(),
              (_isShowSticker ? buildSticker() : Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(const Radius.circular(30.0)),
                  color: Colors.white,
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      padding: const EdgeInsets.all(0.0),
                      icon: Icon(_isShowSticker
                          ? Icons.keyboard
                          : Icons.insert_emoticon),
                      onPressed: () {
                        _isShowSticker
                            ? _inputFocus.requestFocus()
                            : _inputFocus.unfocus();

                        setState(() {
                          _isShowSticker = !_isShowSticker;
                        });
                      },
                    ),
                    Flexible(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(0.0),
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            // color: textFieldHintColor,
                            fontSize: 16.0,
                          ),
                          counterText: '',
                        ),
                        onSubmitted: (String text) {
                          sendMessage();
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        maxLength: TextField.noMaxLength,
                        focusNode: _inputFocus,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                          this._isSlider ? Icons.close : Icons.attach_file),
                      onPressed: onFileIconPressed,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: IconButton(
                onPressed: sendMessage,
                icon: Icon(Icons.send),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onFileSelection(FileType type) async {
    Navigator.of(context).pop();
    var multipleFileType = [FileType.image, FileType.video];
    var result = await FilePicker.platform.pickFiles(
      type: type,
      allowCompression: true,
      allowMultiple: multipleFileType.contains(type),
    );
    if (result == null || result.count == 0) {
      return;
    }
    this._files = result.paths.map((e) => File(e)).toList();
    setState(() {
      this._isSlider = true;
      this._fileType = type;
    });
  }

  void onFileIconPressed() async {
    if (this._isSlider) {
      setState(() {
        this._isSlider = false;
        this._files = null;
        this._fileType = null;
      });
      return;
    }
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).backgroundColor,
        builder: (context) {
          var items = [
            FileSelectionItem(
              Icons.image,
              "Image",
              FileType.image,
              onPressed: onFileSelection,
            ),
            FileSelectionItem(
              Icons.video_collection,
              "Video",
              FileType.video,
              onPressed: onFileSelection,
            ),
            FileSelectionItem(
              Icons.audiotrack,
              "Audio",
              FileType.audio,
              onPressed: onFileSelection,
            ),
            FileSelectionItem(
              Icons.file_present,
              "File",
              FileType.any,
              onPressed: onFileSelection,
            ),
          ];
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 4,
              children: items,
            ),
            height: 100,
          );
        });
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 4,
      columns: 10,
      buttonMode: ButtonMode.MATERIAL,
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        _controller.text += emoji.emoji;
      },
    );
  }

  Widget showConfirmationPreview() {
    return Container(
      child: Column(
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: false,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
            ),
            items: buildSliderItems(
              this._files,
              this._fileType,
              onPressed: (file) {
                setState(() {
                  this._files.remove(file);
                  if (this._files.length == 0) {
                    this._files = null;
                    this._isSlider = false;
                    this._fileType = null;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    var text = this._controller.text;
    if (text.length == 0 && this._files == null) {
      return;
    }
    _sendMessage(text, files: this._files, fileType: this._fileType);

    setState(() {
      this._controller.text = "";
      _isShowSticker = false;
      _isSlider = false;
    });
  }
}
