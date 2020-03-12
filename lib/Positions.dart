import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'model/MediaItem.dart';
import 'model/Balance.dart';
import 'network/MediaRepository.dart';
import 'network/UserRepository.dart';
import 'BalanceBar.dart';
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

var dateFormater = new DateFormat("dd.MM HH:mm");
format(Duration d) => d.toString().substring(0, 5);

class _MyPositionsState extends State<MyPositions> {
  final String currentUserId;
  _MyPositionsState({Key key, @required this.currentUserId});
  List<MediaItemResponse> chartList = List<MediaItemResponse>();
  bool updateLoader = false;
  final balance = Balance();
  num currentPnl = 0.0;
  num currentProfit = 0.0;
  User currentUser;

  @override
  void initState() {
    super.initState();
    _updatePositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your Bets'), actions: <Widget>[
          updateLoader
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator())
              : IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _updatePositions,
                )
        ]),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomNavigation(context, balance));
  }

  Widget _buildBottomNavigation(BuildContext context, balance) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userSnapshot(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        currentUser = User.fromSnapshot(snapshot.data);
        return BalanceBar(currentUser: currentUser, profit: currentProfit);
        //return _buildBalanceBar(context, snapshot.data);
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('positions')
          .document(currentUserId)
          .collection(currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    developer
        .log("_buildList snapshot for user:$currentUserId ${snapshot.length}");
    currentPnl = 0.0;
    currentProfit = 0;
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
    final expiredDuration = _getExpireTime(position.createdAt);

    developer.log(position.toString());

    return Padding(
        key: ValueKey(position.id),
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
        child: Card(
          color: expiredDuration.isNegative ? Colors.black12 : Colors.grey[800],
          elevation: expiredDuration.isNegative ? 1.0 : 5.0,
          child: ListTile(
            leading: _buildCoverImage(context, position),
            title: Text("${position.name}",
                maxLines: 1,
                style: expiredDuration.isNegative
                    ? Styles.mediaRowArtistName
                    : Styles.mediaRowItemName,
                overflow: TextOverflow.ellipsis),
            subtitle: Row(children: <Widget>[
              Text("$direction${position.size}",
                  style: Styles.mediaRowItemName.apply(color: directionColor)),
              Text(" #${position.startPosition}"),
              Text("  at $createdAt", style: Styles.mediaRowArtistName),
            ]),
            trailing: _buildStatistic(position),
          ),
        ));
  }

  Widget _buildStatistic(Position position) {
    final expiredDuration = _getExpireTime(position.createdAt);
    final expiredString =
        expiredDuration.isNegative ? "EXP" : format(expiredDuration);
    final currentPosition = _findCurrentPosition(position);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text("$expiredString", style: Styles.mediaRowArtistName),
        _buildCurrentPosition(currentPosition),
        _buildPNL(position, currentPosition, expiredDuration.isNegative),
      ],
    );
  }

  Duration _getExpireTime(String createdAt) {
    final created = int.tryParse(createdAt);
    final oneDay = Duration(days: 1).inMilliseconds;
    return Duration(
        milliseconds: created + oneDay - DateTime.now().millisecondsSinceEpoch);
  }

  int _findCurrentPosition(Position position) {
    final currentPosition =
        chartList.indexWhere((item) => item.id == position.id);

    return currentPosition > 0 ? chartList[currentPosition].position : null;
  }

  Widget _buildCurrentPosition(int currentPosition) {
    return Text(currentPosition != null ? currentPosition.toString() : "-",
        style: Styles.mediaRowArtistName.apply(color: Colors.white));
  }

  Widget _buildPNL(Position position, int currentIndex, bool isExpired) {
    final pnl = _calculatePnl(position, currentIndex);
    final pnlColor = pnl == null || pnl > 0
        ? Colors.blue
        : pnl < 0.0 ? Colors.red : Colors.green;

    _updateReferenceData(position, currentIndex, pnl, isExpired);

    return Text(pnl == null ? "NAN" : "${pnl}b",
        style: Styles.mediaRowArtistName.apply(color: pnlColor));
  }

  int _calculatePnl(Position position, int currentPosition) {
    if (currentPosition != null) {
      final resultPosition = position.direction == "up"
          ? position.startPosition - currentPosition
          : currentPosition - position.startPosition;
      return resultPosition * position.size;
    } else {
      return null;
    }
  }

  void _updateReferenceData(position, currentIndex, pnl, bool isExpired) async {
    if (pnl != null && !isExpired) {
      currentPnl += pnl != null ? pnl : 0;
      position.reference
          .updateData({'pnl': pnl, 'currentPosition': currentIndex});
    }
    developer.log(
        "_updateReferenceData pnl:$pnl,isExpired:$isExpired,currentPnl:$currentPnl");
    if (currentUser != null) {
      if (isExpired) currentProfit += position.pnl == null ? 0 : position.pnl;

      currentUser.reference
          .updateData({'pnl': currentPnl, 'profit': currentProfit});
    }
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

  Future<Null> _updatePositions() async {
    setState(() {
      updateLoader = true;
    });
    Fluttertoast.showToast(msg: "Reload data...");

    fetchChartList().then(
        (value) => setState(() {
              updateLoader = false;
              chartList = value;
            }),
        onError: (e) => e.printStackTrace());
  }
}

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
}
