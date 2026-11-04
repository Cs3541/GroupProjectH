import 'package:flutter/foundation.dart';
import '../models/routine_model.dart';

class RoutinePresenter extends ChangeNotifier {
  RoutinePresenter._();
  static final RoutinePresenter instance = RoutinePresenter._();

  final List<Routine> _routines = [];

  List<Routine> get routines => List.unmodifiable(_routines);

  void addRoutine(Routine routine) {
    _routines.add(routine);
    notifyListeners();
  }

  void removeRoutine(int index) {
    _routines.removeAt(index);
    notifyListeners();
  }
}