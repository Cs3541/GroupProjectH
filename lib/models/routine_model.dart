class Routine {
  final String id;
  final String name;
  final List<String> exerciseIds;

  Routine({
    required this.id,
    required this.name,
    required this.exerciseIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exerciseIds': exerciseIds,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      exerciseIds: List<String>.from(map['exerciseIds']),
    );
  }
  
}