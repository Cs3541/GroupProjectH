import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/step_model.dart';

class StepPresenter extends ChangeNotifier {
  static final StepPresenter instance = StepPresenter._internal();

  StepPresenter._internal();

  final StepModel _model = StepModel();

  StreamSubscription<StepCount>? _subscription;

  int get steps => _model.steps;

  String? errorMessage;

  Future<void> startTracking() async {
    if (_subscription != null) return;

    final permission = await Permission.activityRecognition.request();

    if (!permission.isGranted) {
      errorMessage = 'Activity recognition permission required';
      notifyListeners();
      return;
    }

    _subscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        _model.updateSteps(event.steps);
        errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        errorMessage = 'Step counter unavailable';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}