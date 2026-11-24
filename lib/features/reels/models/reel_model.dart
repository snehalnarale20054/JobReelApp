class ReelModel {
  final String id;
  final String streamUid;
  final String playbackUrl;
  final String? thumbnailUrl;
  final String? caption;
  final List<String> skillTags;
  final String uploaderName;
  final int likeCount;
  final DateTime createdAt;

  const ReelModel({
    required this.id,
    required this.streamUid,
    required this.playbackUrl,
    this.thumbnailUrl,
    this.caption,
    required this.skillTags,
    required this.uploaderName,
    required this.likeCount,
    required this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] as String,
      streamUid: json['stream_uid'] as String,
      playbackUrl: json['playback_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] as String?,
      skillTags: List<String>.from(json['skill_tags'] as List),
      uploaderName: json['uploader_name'] as String,
      likeCount: json['like_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
