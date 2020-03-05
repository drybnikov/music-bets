import 'package:flutter/material.dart';
import 'dart:async';

import 'model/MediaItem.dart';
import 'network/MediaRepository.dart';

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
      appBar: AppBar(title: Text('Weekly Chart')),
      body: _buildBody(context),
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
      padding: const EdgeInsets.only(top: 2.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, MediaItemResponse data) {
    return Padding(
      key: ValueKey(data.id),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Container(
        child: ListTile(
            title: Text("${data.name}"),
            subtitle: Text("${data.artistName}",
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                    color: Colors.grey)),
            leading: Image.network(
              data.coverImage,
              cacheHeight: 52,
              cacheWidth: 52,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Chip(
                  label: Icon(Icons.trending_up),
                  backgroundColor: Colors.lightBlue,
                  labelPadding: const EdgeInsets.only(right: 2.0, left: 2.0),
                ),
                Chip(
                  label: Icon(Icons.trending_down),
                  backgroundColor: Colors.red,
                  labelPadding: const EdgeInsets.only(right: 2.0, left: 2.0),
                ),
              ],
            )),
      ),
    );
  }
}
