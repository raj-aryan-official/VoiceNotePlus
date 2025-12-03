class Note {
  final dynamic id;
  final String title;
  final String content;
  final String dateTime;
  final String tags;
  final bool isLiked;
  final String recordingPath;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.tags = '',
    this.isLiked = false,
    this.recordingPath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateTime': dateTime,
      'tags': tags,
      'isLiked': isLiked,
      'recordingPath': recordingPath,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      dateTime: map['dateTime'] ?? '',
      tags: map['tags'] ?? '',
      isLiked: map['isLiked'] ?? false,
      recordingPath: map['recordingPath'] ?? '',
    );
  }
}
