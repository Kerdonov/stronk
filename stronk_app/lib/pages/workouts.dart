import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO new workout
        },
        child: const Text("+", style: TextStyle(fontSize: 20)),
      ),
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
              List<Widget> sets = List.from([]);
              for (var (weight, reps) in workout.sets) {
                String plural = reps == 1 ? "rep" : "reps";
                sets.add(
                  Row(
                    children: [
                      Expanded(child: Text("$weight kg")),
                      Expanded(child: Text("$reps $plural")),
                    ],
                  ),
                );
              }
              return GestureDetector(
                onLongPress: () {
                  // TODO delete workout?
                  print("delete workout ${workout.id}");
                },
                child: ExpansionTile(
                  title: Text(
                    DateFormat("y MMM d HH:mm").format(
                      DateTime.fromMillisecondsSinceEpoch(
                        (workout.timestamp * 1000),
                      ),
                    ),
                  ),
                  subtitle: Text("${workout.sets.length.toString()} sets"),
                  expandedAlignment: Alignment.centerLeft,
                  childrenPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 13.0,
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: sets,
                ),
              );
            },
          ),
    );
  }
}
