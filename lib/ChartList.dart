import 'dart:async';
import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'AudioPlayerDemo.dart';
import 'Positions.dart';
import 'login.dart';
import 'googleLogin.dart';
import 'model/MediaItem.dart';
import 'network/MediaRepository.dart';
import 'styles.dart';

void main() => runApp(MyApp());

class ChartList extends StatelessWidget {
  final String currentUserId;

  ChartList({Key key, @required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Bets',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
      ),
      home: ChartListHome(),
    );
  }
}

class ChartListHome extends StatefulWidget {
  @override
  _ChartListHome createState() {
    return _ChartListHome();
  }
}

class _ChartListHome extends State<ChartListHome> {
  Future<List<MediaItemResponse>> futureChartList;
  String currentItem = "";

  @override
  void initState() {
    super.initState();
    futureChartList = fetchChartList();
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
        ],
      ),
      body: _buildBody(context),
    );
  }

  void _openPositions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return MyPositions();
        },
      ),
    );
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
    return ListView(
      padding: const EdgeInsets.only(top: 0.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, MediaItemResponse data) {
    return Padding(
      key: ValueKey(data.id),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
      child: Card(
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
                ActionChip(
                  label: Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    semanticLabel: "hey",
                  ),
                  backgroundColor: Colors.lightBlue,
                  onPressed: () {
                    print("Up to: ${data.name}");
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                ),
                ActionChip(
                  label: Icon(
                    Icons.trending_down,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.red,
                  shadowColor: Colors.white30,
                  onPressed: () {
                    final snackBar =
                        SnackBar(content: Text("Down to: ${data.name}"));
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                ),
              ],
            )),
      ),
    );
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
        itemSelected ? _buildPlayer(context, data) : Icon(Icons.error)
      ]),
    );
  }

  Widget _buildPlayer(BuildContext context, MediaItemResponse data) {
    return AudioPlayerDemo(data.filePath);
  }
}
