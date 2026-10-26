import 'package:mindo_kids/core/utils/map_reader.dart';

/// A picture that is either an uploaded image (Firebase Storage download
/// URL) or an emoji fallback. Every visual in the app is a MediaRef, so the
/// admin panel can start with emojis and swap in real illustrations later.
class MediaRef {
  final String imageUrl;
  final String emoji;

  const MediaRef({this.imageUrl = '', this.emoji = ''});

  factory MediaRef.fromMap(Map<String, dynamic> m, {String imageKey = 'imageUrl', String emojiKey = 'emoji'}) =>
      MediaRef(imageUrl: m.str(imageKey), emoji: m.str(emojiKey));

  bool get isEmpty => imageUrl.isEmpty && emoji.isEmpty;
  bool get hasImage => imageUrl.isNotEmpty;

  Map<String, dynamic> toMap({String imageKey = 'imageUrl', String emojiKey = 'emoji'}) => {
    imageKey: imageUrl,
    emojiKey: emoji,
  };
}
