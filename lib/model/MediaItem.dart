class MediaItemResponse {
  final String id;
  final String name;
  final int plays;
  final int likes;
  final int comments;
  final int position;
  final String artistName;
  final String coverImage;
  final String filePath;

  MediaItemResponse(
      {this.id,
      this.name,
      this.plays,
      this.likes,
      this.comments,
      this.position,
      this.artistName,
      this.coverImage,
      this.filePath});

  factory MediaItemResponse.fromJson(Map<String, dynamic> json, int position) {
    return new MediaItemResponse(
        id: json['id'].toString(),
        name: json['name'],
        plays: json['plays'],
        likes: json['likes'],
        comments: json['comments'],
        position: position,
        artistName: json['artist_name'],
        coverImage: json['cover_image_path'],
        filePath: json['music_file_path']);
  }
}
