import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final dateFormater = DateFormat("dd.MM HH:mm");

class Position {
  final String userid;
  final String id;
  final String direction;
  final int size;
  final String createdAt;
  final String name;
  final String artistName;
  final String coverImage;
  final String filePath;
  final int startPosition;
  final num pnl;

  final DocumentReference reference;

  Position.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['userid'] != null),
        assert(map['id'] != null),
        userid = map['userid'],
        id = map['id'],
        direction = map['direction'],
        size = map['size'],
        createdAt = map['createdAt'],
        name = map['name'],
        artistName = map['artistName'],
        coverImage = map['coverImage'],
        filePath = map['filePath'],
        startPosition = map['startPosition'],
        pnl = map['pnl'];

  Position.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Position<$name:$direction>";

  String get directionSign => direction == "up" ? '+' : '-';
  Color get directionColor => direction == "up" ? Colors.blue : Colors.red;
  String get created => dateFormater
      .format(DateTime.fromMillisecondsSinceEpoch(int.tryParse(createdAt)));
  Duration get expired => _getExpireTime(createdAt);
  String get expiredString => expired.isNegative ? "EXP" : _format(expired);

  Duration _getExpireTime(String createdAt) {
    final created = int.tryParse(createdAt);
    final oneDay = Duration(days: 1).inMilliseconds;
    return Duration(
        milliseconds: created + oneDay - DateTime.now().millisecondsSinceEpoch);
  }

  _format(Duration d) => d.toString().substring(0, 5);
}
