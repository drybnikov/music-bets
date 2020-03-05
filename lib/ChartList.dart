import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'model/MediaItem.dart';

class ChartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Bets',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
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
            return Text(snapshot.data.toString());
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

Future<List<MediaItemResponse>> fetchChartList() async {
  var url = 'https://api.jam-community.com/song/hottest/last7';
  var response = await http.get(url);
  if (response.statusCode == 200) {
    final jsonResponse = convert.jsonDecode(response.body) as List;
    return jsonResponse.map((e) => new MediaItemResponse.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load album');
  }
}
