import 'package:flutter/material.dart';
import 'package:get_fit/models/exercise_model.dart';
import '../home_screen.dart';
import 'log_workout_screen.dart';
import 'routine_list_screen.dart';
import 'progress_screen.dart';
import 'exercise_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onNavigate: _onItemTapped),
          const LogWorkoutScreen(),
          const RoutineListScreen(),
          const ProgressScreen(),
          ExerciseListScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dns),
            label: 'Exercises',
          ),
        ],
      ),
    );
  }
}