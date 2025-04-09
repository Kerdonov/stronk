import 'package:flutter/material.dart';
import 'package:stronk_app/models/workout.dart';
import 'package:stronk_app/services/db_service.dart';

class WorkoutsPage extends StatefulWidget {
  final String group;
  final String exercise;

  const WorkoutsPage({super.key, required this.group, required this.exercise});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise)),
      body: workoutsList(),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
    );
  }

  Widget workoutsList() {
    return FutureBuilder(
      future: _databaseService.getAllExerciseWorkouts(widget.exercise),
      builder:
          (context, snapshot) => ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Workout workout = snapshot.data![index];
              return Row(
                children: [
                  Text(workout.date),
                  Text(workout.sets.length.toString()),
                ],
              );
            },
          ),
    );
  }
}
