import 'package:flutter/material.dart';
import 'package:stronk_app/models/exercise.dart';
import 'package:stronk_app/pages/workouts.dart';
import 'package:stronk_app/services/db_service.dart';
import 'package:stronk_app/widgetbuilders/dialog.dart';

class ExercisePage extends StatefulWidget {
  final String groupName;

  const ExercisePage({super.key, required this.groupName});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Widget exerciseList;

  @override
  void initState() {
    super.initState();
    exerciseList = buildExerciseList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: exerciseList,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPostDialog(
            context,
            "New \"${widget.groupName}\" exercise",
            "Exercise name",
            (exerciseName) {
              _databaseService.newExercise(widget.groupName, exerciseName).then(
                (success) {
                  if (success) {
                    setState(() {
                      exerciseList = buildExerciseList();
                    });
                  }
                },
              );
            },
            (name) {
              if ((name ?? "").length > 30) {
                return "Cannot be more than 30 characters";
              }
              return null;
            },
          );
        },
        child: const Text("+", style: TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget buildExerciseList() {
    return FutureBuilder(
      future: _databaseService.getExercises(widget.groupName),
      builder:
          (context, snapshot) => ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Exercise exercise = snapshot.data![index];
              return TextButton(
                child: ListTile(title: Text(exercise.name)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => WorkoutsPage(
                            group: widget.groupName,
                            exercise: exercise.name,
                          ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
