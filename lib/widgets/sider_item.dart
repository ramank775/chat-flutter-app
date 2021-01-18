import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SliderFileItem extends StatelessWidget {
  final File file;
  final int count;
  final int total;
  final FileType type;
  final Function(File file) onPressed;
  const SliderFileItem({
    Key key,
    this.file,
    this.type,
    this.count,
    this.total,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        margin: EdgeInsets.all(2.0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
            child: Stack(
              children: <Widget>[
                buildPreview(),
                Positioned(
                  bottom: 0.0,
                  left: -10.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      this.getFileCaption(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -10.0,
                  right: -30.0,
                  child: RawMaterialButton(
                    onPressed: () {
                      if (this.onPressed != null) {
                        this.onPressed(this.file);
                      }
                    },
                    elevation: 1.0,
                    fillColor: Colors.transparent,
                    child: Icon(
                      Icons.close,
                      size: 30.0,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(0.0),
                    shape: CircleBorder(),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget buildPreview() {
    if (this.type == FileType.image) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: 1000.0,
        errorBuilder: (context, error, stackTrace) {
          return NoPreview();
        },
      );
    }
    return NoPreview();
  }

  getFileCaption() {
    if (this.count > 0 && this.total > 0) {
      return "${this.count}/${this.total}";
    }
    if (this.count > 0) {
      return this.count.toString();
    }
  }
}

class NoPreview extends StatelessWidget {
  const NoPreview({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.no_photography),
          Text("No Preview available"),
        ],
      ),
    );
  }
}

List<SliderFileItem> buildSliderItems(List<File> files, FileType type,
    {Function(File file) onPressed}) {
  return files
      .map((f) => SliderFileItem(
            file: f,
            type: type,
            total: files.length,
            count: files.indexOf(f) + 1,
            onPressed: onPressed,
          ))
      .toList();
}
