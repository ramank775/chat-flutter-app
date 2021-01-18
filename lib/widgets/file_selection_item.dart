import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileSelectionItem extends StatelessWidget {
  final IconData _icon;
  final String _text;
  final FileType type;
  final Function(FileType type) onPressed;
  const FileSelectionItem(
    this._icon,
    this._text,
    this.type, {
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed(this.type);
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(
              this._icon,
              color: Colors.white,
              size: 30.0,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          Text(
            this._text,
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}
