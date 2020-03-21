import 'dart:async';
import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/ThemeBloc.dart';
import 'authentication/authentication.dart';
import 'BalanceBar.dart';

import 'ui/ConfirmationWidget.dart';
import 'AudioPlayerDemo.dart';
import 'Positions.dart';
import 'model/MediaItem.dart';
import 'model/Position.dart';
import 'network/MediaRepository.dart';
import 'network/PositionRepository.dart';
import 'styles.dart';

import 'chipsInput.dart';

class ChartList extends StatelessWidget {
  final String currentUserId;

  ChartList({Key key, @required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: context.bloc<ThemeBloc>(),
        child: BlocBuilder<ThemeBloc, ThemeData>(builder: (_, theme) {
          return MaterialApp(
            theme: theme,
            home: ChartListHome(currentUserId: currentUserId),
          );
        }));
  }
}

class ChartListHome extends StatefulWidget {
  final String currentUserId;
  ChartListHome({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _ChartListHome createState() {
    return _ChartListHome();
  }
}

class _ChartListHome extends State<ChartListHome> {
  Future<List<MediaItemResponse>> futureChartList;
  String currentItem = "";
  List<Position> _positionsList = List<Position>();
  BalanceBar _balanceBar;

  @override
  void initState() {
    super.initState();
    futureChartList = fetchChartList();
    _balanceBar = BalanceBar(currentUserId: widget.currentUserId);
    _loadPositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Weekly Chart'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.developer_board,
                  color: Colors.cyanAccent,
                ),
                onPressed: _openPositions),
            IconButton(icon: Icon(Icons.input), onPressed: _openChips),
            IconButton(icon: Icon(Icons.update), onPressed: _switchTheme),
            IconButton(icon: Icon(Icons.exit_to_app), onPressed: _loggedOut),
          ],
        ),
        body: _buildBody(context),
        bottomNavigationBar: _balanceBar);
  }

  void _openChips() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ChipsPage();
        },
      ),
    );
  }

  void _openPositions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return MyPositions(currentUserId: widget.currentUserId);
        },
      ),
    );
  }

  void _loggedOut() {
    context.bloc<AuthenticationBloc>().add(LoggedOut());
  }

  void _switchTheme() {
    context.bloc<ThemeBloc>().add(ThemeEvent.toggle);
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: FutureBuilder<List<MediaItemResponse>>(
        future: futureChartList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildList(context, snapshot.data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<MediaItemResponse> snapshot) {
    _balanceBar.updateBalance(snapshot, _positionsList);
    return ListView(
      padding: const EdgeInsets.only(top: 0.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, MediaItemResponse data) {
    final itemIndex = _positionsList.indexWhere((item) => item.id == data.id);
    developer.log("_buildListItem itemIndex:$itemIndex, id:${data.id}");

    return Padding(
      key: ValueKey(data.id),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
      child: Card(
        color: itemIndex >= 0 ? Colors.grey[700] : Colors.grey[800],
        elevation: 4.0,
        child: ListTile(
            title: Text("${data.name}",
                maxLines: 1,
                style: Styles.mediaRowItemName,
                overflow: TextOverflow.ellipsis),
            subtitle:
                Text("${data.artistName}", style: Styles.mediaRowArtistName),
            leading: _buildCoverImage(context, data),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTradeAction(context, data, true),
                Padding(padding: const EdgeInsets.only(left: 8.0)),
                _buildTradeAction(context, data, false)
              ],
            )),
      ),
    );
  }

  Widget _buildTradeAction(
      BuildContext context, MediaItemResponse mediaItem, bool moveUp) {
    return ActionChip(
      label: Icon(
        moveUp ? Icons.trending_up : Icons.trending_down,
        color: Colors.white,
      ),
      backgroundColor: moveUp ? Colors.lightBlue : Colors.red,
      shadowColor: Colors.white30,
      onPressed: () {
        handleCreatePosition(context, mediaItem, moveUp ? "up" : "down");
      },
    );
  }

  void handleCreatePosition(
      BuildContext context, MediaItemResponse data, String direction) {
    showBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 220,
              child: ConfirmationWidget(
                  create: CreatePosition(
                      currentUserId: widget.currentUserId,
                      mediaItem: data,
                      direction: direction)),
            ));
  }

  Widget _buildCoverImage(BuildContext context, MediaItemResponse data) {
    final bool itemSelected = data.id == currentItem;
    developer.log("_buildCoverImage itemSelected:$itemSelected, id:${data.id}");

    return InkWell(
      onTap: () {
        print("tapped on:${data.id}");
        setState(() {
          currentItem = data.id;
        });
      },
      child: Stack(children: <Widget>[
        Container(
          child: CachedNetworkImage(
            imageUrl: data.coverImage,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            width: 72,
            height: 72,
          ),
        ),
        itemSelected
            ? _buildPlayer(context, data)
            : Container(
                width: 24.0,
                height: 24.0,
              )
      ]),
    );
  }

  Widget _buildPlayer(BuildContext context, MediaItemResponse data) {
    return AudioPlayerDemo(data.filePath);
  }

  Future<Null> _loadPositions() async {
    positionsSnapshot(widget.currentUserId).listen((snapshot) {
      _positionsList = snapshot.documents
          .map((data) => Position.fromSnapshot(data))
          .toList();
    });
  }
}
