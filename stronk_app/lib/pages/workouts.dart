import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stronk_app/models/workout.dart';
import 'package:stronk_app/pages/add_workout.dart';
import 'package:stronk_app/services/db_service.dart';
import 'package:stronk_app/widgets/confirm_dialog.dart';
import 'package:stronk_app/widgets/set_widget.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWorkout(exerciseName: widget.exercise),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
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
              int i = 1;
              for (var (weight, reps) in workout.sets) {
                sets.add(SetWidget(n: i++, weight: weight, reps: reps));
              }
              final plural = workout.sets.length == 1 ? "set" : "sets";
              return GestureDetector(
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  showConfirmationDialog(context, "Delete workout?").then((
                    confirm,
                  ) {
                    if (confirm ?? false) {
                      _databaseService.removeWorkout(workout.id);
                      setState(() {});
                    }
                  });
                },
                child: ExpansionTile(
                  title: Text(
                    DateFormat("y MMM d HH:mm").format(
                      DateTime.fromMillisecondsSinceEpoch(
                        (workout.timestamp * 1000),
                      ),
                    ),
                  ),
                  subtitle: Text("${workout.sets.length.toString()} $plural"),
                  expandedAlignment: Alignment.centerLeft,
                  childrenPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 15.0,
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
