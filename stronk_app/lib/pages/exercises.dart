import 'package:flutter/material.dart';
import 'package:stronk_app/models/exercise.dart';
import 'package:stronk_app/pages/workouts.dart';
import 'package:stronk_app/services/db_service.dart';

class ExercisePage extends StatefulWidget {
  final String groupName;

  const ExercisePage({super.key, required this.groupName});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: Text(widget.groupName),
      ),
      body: exerciseList(),
    );
  }

  Widget exerciseList() {
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
