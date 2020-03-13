import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'model/MediaItem.dart';
import 'model/Balance.dart';
import 'model/Position.dart';
import 'network/MediaRepository.dart';
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

class _MyPositionsState extends State<MyPositions> {
  final String currentUserId;
  _MyPositionsState({Key key, @required this.currentUserId});

  List<MediaItemResponse> chartList = List<MediaItemResponse>();
  bool updateLoader = false;
  final _balance = Balance();
  BalanceBar _balanceBar;

  @override
  void initState() {
    super.initState();
    _updatePositions();
    _balanceBar = BalanceBar(currentUserId: currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Your Bets'), actions: <Widget>[_buildRefreshAction()]),
        body: _buildBody(context),
        bottomNavigationBar: _balanceBar);
  }

  Widget _buildRefreshAction() {
    return updateLoader
        ? Padding(
            padding: const EdgeInsets.all(10),
            child: CircularProgressIndicator())
        : IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _updatePositions,
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
    _balance.clearBalance();
    return ListView(
      padding: const EdgeInsets.only(top: 16.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final position = Position.fromSnapshot(data);

    developer.log(position.toString());

    return Padding(
        key: ValueKey(position.id),
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
        child: Card(
          color:
              position.expired.isNegative ? Colors.black12 : Colors.grey[800],
          elevation: position.expired.isNegative ? 1.0 : 5.0,
          child: ListTile(
            leading: _buildCoverImage(context, position),
            title: Text("${position.name}",
                maxLines: 1,
                style: position.expired.isNegative
                    ? Styles.mediaRowArtistName
                    : Styles.mediaRowItemName,
                overflow: TextOverflow.ellipsis),
            subtitle: Row(children: <Widget>[
              Text("${position.directionSign}${position.size}",
                  style: Styles.mediaRowItemName
                      .apply(color: position.directionColor)),
              Text(" #${position.startPosition}"),
              Text("  at ${position.created}",
                  style: Styles.mediaRowArtistName),
            ]),
            trailing: _buildStatistic(position),
          ),
        ));
  }

  Widget _buildStatistic(Position position) {
    final currentPosition = _findPosition(position);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text("${position.expiredString}", style: Styles.mediaRowArtistName),
        _buildCurrentPosition(currentPosition),
        _buildPNL(position, currentPosition, position.expired.isNegative),
      ],
    );
  }

  int _findPosition(Position position) {
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
      _balance.updatePnl(pnl);
      position.reference
          .updateData({'pnl': pnl, 'currentPosition': currentIndex});
    }
    developer.log(
        "_updateReferenceData pnl:$pnl,isExpired:$isExpired,currentPnl:$_balance.currentPnl");
    if (_balanceBar != null && _balanceBar.currentUser != null) {
      if (isExpired) _balance.updateBalance(position.pnl);

      _balanceBar.currentUser.reference
          .updateData({'pnl': _balance.currentPnl, 'profit': _balance.profit});
    }
  }

  Widget _buildCoverImage(BuildContext context, Position data) {
    return CachedNetworkImage(
      imageUrl: data.coverImage,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Container(),
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
            }), onError: (e) {
      Fluttertoast.showToast(msg: "Network Error.");
      setState(() => updateLoader = false);
      e.printStackTrace();
    });
  }
}
