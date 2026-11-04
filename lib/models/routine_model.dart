class Routine {
  final String id;
  final String name;
  final List<String> workoutNames;

  Routine({
    required this.id,
    required this.name,
    required this.workoutNames,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'workoutNames': workoutNames,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      workoutNames: List<String>.from(map['workoutNames']),
    );
  }
  
}