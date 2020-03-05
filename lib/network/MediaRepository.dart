import '../model/MediaItem.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<MediaItemResponse>> fetchChartList() async {
  var url = 'https://api.jam-community.com/song/hottest/last7';
  var response = await http.get(url);
  if (response.statusCode == 200) {
    return compute(_parseMediaItems, response.body);
  } else {
    throw Exception('Failed to load album');
  }
}

List<MediaItemResponse> _parseMediaItems(String responseBody) {
  final parsed = jsonDecode(responseBody) as List;
  return parsed.map((json) => MediaItemResponse.fromJson(json)).toList();
}
