import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future loadChartList() async {
    var url = 'https://www.googleapis.com/books/v1/volumes?q={http}';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body) as List;
      List<MediaItemResponse> mediaList = jsonResponse.map((e) => new MediaItemResponse.fromJson(e)).toList();
      print(mediaList);
    }
  }
}

class _ChartListHome extends State<ChartListHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Chart')),
      //body: _buildBody(context),
    );
  }
}