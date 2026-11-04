class Exercise {
  final String id;
  final String name;
  final int? sets;
  final int? reps;
  final double? weight;
  final int? duration;
  final int? distance;

  Exercise({
    required this.id,
    required this.name,
    this.sets,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
      duration: map['duration'],
      distance: map['distance'],
    );
  }
  
}