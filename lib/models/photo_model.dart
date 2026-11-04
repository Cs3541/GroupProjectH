class Photo {
  final String id;
  final String path;
  final DateTime dateTaken;
  final DateTime dateUploaded;
  bool isFavorite;

  Photo({
    required this.id,
    required this.path,
    required this.dateTaken,
    required this.dateUploaded,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'dateTaken': dateTaken.toIso8601String(),
      'dateUploaded': dateUploaded.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      path: map['path'],
      dateTaken: DateTime.parse(map['dateTaken']),
      dateUploaded: DateTime.parse(map['dateUploaded']),
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}