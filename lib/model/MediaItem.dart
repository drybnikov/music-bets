class MediaItemResponse {
  final String id;
  final String name;
  final String userId;
  final String type;
  final String artistName;
  final String coverImage;
  final String filePath;


  MediaItemResponse({
    this.id,
    this.name,
    this.userId,
    this.type,
    this.artistName,
    this.coverImage,
    this.filePath
  });

  factory MediaItemResponse.fromJson(Map<String, dynamic> json) {
    return new MediaItemResponse(
        id: json['id'].toString(),
        name: json['name'],
        userId: json['user_id'],
        type: json['type'],
        artistName: json['artist_name'],
        coverImage: json['cover_image_path'],
        filePath: json['file_path']
    );
  }
}