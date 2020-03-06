import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'model/MediaItem.dart';
import 'network/MediaRepository.dart';
import 'styles.dart';
import 'Positions.dart';

void main() => runApp(ChartList());

class ChartList extends StatelessWidget {
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

  @override
  void initState() {
    super.initState();
    futureChartList = fetchChartList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Chart'), centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.developer_board, color: Colors.cyanAccent,), onPressed: _openPositions),
        ],),
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
            subtitle: Text("${data.artistName}", style: Styles.mediaRowArtistName),
            leading: CachedNetworkImage(
              imageUrl: data.coverImage,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 72,
              height: 72,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ActionChip(
                  label: Icon(Icons.trending_up, color: Colors.white, semanticLabel: "hey",),
                  backgroundColor: Colors.lightBlue,
                  onPressed: () {
                    print("Up to: ${data.name}");
                  },
                ),
                Padding(padding: const EdgeInsets.only(left: 8.0),),
                ActionChip(
                  label: Icon(Icons.trending_down, color: Colors.black,),
                  backgroundColor: Colors.red,
                  shadowColor: Colors.white30,
                  onPressed: () {
                    print("Down to: ${data.name}");
                  },
                ),
              ],
            )),
      ),
    );
  }
}
