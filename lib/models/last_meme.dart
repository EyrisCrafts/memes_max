import 'dart:convert';

class LastMeme {
  String lastID;
  DateTime lastAccessed;
  LastMeme({
    required this.lastID,
    required this.lastAccessed,
  });

  LastMeme copyWith({
    String? lastID,
    DateTime? lastAccessed,
  }) {
    return LastMeme(
      lastID: lastID ?? this.lastID,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastID': lastID,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
    };
  }

  factory LastMeme.fromMap(Map<String, dynamic> map) {
    return LastMeme(
      lastID: map['lastID'] ?? '',
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(map['lastAccessed']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LastMeme.fromJson(String source) =>
      LastMeme.fromMap(json.decode(source));

  @override
  String toString() => 'LastMeme(lastID: $lastID, lastAccessed: $lastAccessed)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LastMeme &&
        other.lastID == lastID &&
        other.lastAccessed == lastAccessed;
  }

  @override
  int get hashCode => lastID.hashCode ^ lastAccessed.hashCode;
}
