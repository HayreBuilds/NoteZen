/// Data model representing a Note stored via the JSONPlaceholder API.
class Note {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Deserialise from API JSON response.
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// Serialise to JSON for POST / PUT request body.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  /// Returns a copy of this Note with selected fields replaced.
  Note copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  String toString() => 'Note(id: $id, title: $title)';
}
