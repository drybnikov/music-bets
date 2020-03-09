import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'styles.dart';

class Positions extends StatelessWidget {
  final String currentUserId;
  Positions({Key key, @required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Bets',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
      ),
      home: MyPositions(currentUserId: currentUserId),
    );
  }
}

class MyPositions extends StatefulWidget {
  final String currentUserId;
  MyPositions({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _MyPositionsState createState() {
    return _MyPositionsState(currentUserId: currentUserId);
  }
}

class _MyPositionsState extends State<MyPositions> {
  final String currentUserId;
  _MyPositionsState({Key key, @required this.currentUserId});

  var dateFormater = new DateFormat("MM.dd HH:mm");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Bets')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('positions')
          .document(currentUserId)
          .collection(currentUserId)
          .snapshots(),
      builder: (cont3ext, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    developer.log("snapshot for user:$currentUserId ${snapshot.toString()}");
    return ListView(
      padding: const EdgeInsets.only(top: 16.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final position = Position.fromSnapshot(data);
    final direction = position.direction == "up" ? '+' : '-';
    final directionColor =
        position.direction == "up" ? Colors.blue : Colors.red;
    final createdAt = dateFormater.format(
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(position.createdAt)));
    final expired = dateFormater.formatDurationFrom(
        calculateExpireTime(position.createdAt), DateTime.now());
    final pnl = position.startPosition - position.startPosition * position.size;

    developer.log(position.toString());

    return Padding(
      key: ValueKey(position.id),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
      child: Card(
        elevation: 2.0,
        child: ListTile(
            leading: _buildCoverImage(context, position),
            title: Text("${position.name}",
                maxLines: 1,
                style: Styles.mediaRowItemName,
                overflow: TextOverflow.ellipsis),
            subtitle: Row(children: <Widget>[
              Text("$direction${position.size}",
                  style: Styles.mediaRowItemName.apply(color: directionColor)),
              Text(" #${position.startPosition}"),
              Text("  at $createdAt", style: Styles.mediaRowArtistName),
            ]),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("$expired", style: Styles.mediaRowArtistName),
                Text("${position.startPosition}",
                    style:
                        Styles.mediaRowArtistName.apply(color: Colors.white)),
                Text("$pnl",
                    style:
                        Styles.mediaRowArtistName.apply(color: directionColor)),
              ],
            )),
      ),
    );
  }

  Duration calculateExpireTime(String createdAt) {
    final created = int.tryParse(createdAt);
    final oneDay = Duration(days: 1).inMicroseconds;

    return Duration(
        milliseconds:
            (created + oneDay)); // - DateTime.now().millisecondsSinceEpoch
  }

  Widget _buildCoverImage(BuildContext context, Position data) {
    return CachedNetworkImage(
      imageUrl: data.coverImage,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      width: 72,
      height: 72,
    );
  }
}
//record.reference.updateData({'votes': FieldValue.increment(1)}),

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
        startPosition = map['startPosition'];

  Position.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Position<$name:$direction>";
}
