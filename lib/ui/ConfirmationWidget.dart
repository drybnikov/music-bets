import 'dart:async';

import 'package:musicbets/model/MediaItem.dart';
import 'package:musicbets/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePosition {
  final String currentUserId;
  final MediaItemResponse mediaItem;
  final String direction;

  CreatePosition(
      {@required this.currentUserId,
      @required this.mediaItem,
      @required this.direction});
}

class ConfirmationWidget extends StatefulWidget {
  final CreatePosition create;
  ConfirmationWidget({@required this.create});

  @override
  _ConfirmationWidgetState createState() =>
      _ConfirmationWidgetState();
}

class _ConfirmationWidgetState extends State<ConfirmationWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(children: [Text("Open position:", style: Styles.title)]),
              Row(children: [
                Text(" name: "),
                Text("${widget.create.mediaItem.name}", style: Styles.mediaRowItemName)
              ]), //"
              Row(children: [
                Text(" size: "),
                Text("10", style: Styles.title.apply(color: Colors.greenAccent))
              ]),
              Row(children: [
                Text(" chart number: "),
                Text("#${widget.create.mediaItem.position + 1}",
                    style: Styles.title.apply(color: directionColor))
              ]),
              Row(children: [
                Text(" dirrection: "),
                Text("${widget.create.direction}",
                    style: Styles.title.apply(color: directionColor))
              ]),
              Row(children: [Text(" reference: ${widget.create.mediaItem.id}")]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    width: 160,
                    height: 48,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [SheetButton(create: widget.create)]))
              ])
            ]));
  }

  String get directionSign => widget.create.direction == "up" ? '+' : '-';
  Color get directionColor =>
      widget.create.direction == "up" ? Colors.blue : Colors.red;
}

class SheetButton extends StatefulWidget {
  final CreatePosition create;
  SheetButton({@required this.create});

  _SheetButtonState createState() => _SheetButtonState();
}

class _SheetButtonState extends State<SheetButton> {
  bool checkingFlight = false;
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return !checkingFlight
        ? MaterialButton(
            color: Colors.grey[800],
            onPressed: () => _placePosition(),
            child: Text(
              'Place position',
              style: TextStyle(color: Colors.white),
            ),
          )
        : !success
            ? CircularProgressIndicator()
            : Icon(
                Icons.check,
                color: Colors.green,
              );
  }

  Future<Null> _placePosition() async {
    setState(() {
      checkingFlight = true;
    });
    await _handleCreatePosition(context);
    setState(() {
      success = true;
    });

    await Future.delayed(Duration(milliseconds: 800));
    Navigator.pop(context);
  }

  Future<Null> _handleCreatePosition(BuildContext context) async {
    String positionId = DateTime.now().millisecondsSinceEpoch.toString();
    await Future.delayed(Duration(milliseconds: 500));

    Firestore.instance
        .collection('positions')
        .document(widget.create.currentUserId)
        .collection(widget.create.currentUserId)
        .document(positionId)
        .setData({
          'userid': widget.create.currentUserId,
          'id': widget.create.mediaItem.id,
          'direction': widget.create.direction,
          'size': 10,
          'createdAt': positionId,
          'name': widget.create.mediaItem.name,
          'artistName': widget.create.mediaItem.artistName,
          'coverImage': widget.create.mediaItem.coverImage,
          'filePath': widget.create.mediaItem.filePath,
          'startPosition': widget.create.mediaItem.position
        })
        .whenComplete(() => print("Complete"))
        .catchError((error) => print(error));
  }
}
