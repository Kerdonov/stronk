import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stronk_app/services/db_service.dart';
import 'package:stronk_app/widgets/confirm_dialog.dart';
import 'package:stronk_app/widgets/set_widget.dart';

class AddWorkout extends StatefulWidget {
  final String exerciseName;
  const AddWorkout({super.key, required this.exerciseName});

  @override
  State<AddWorkout> createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<AddWorkout> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late List<(num, int)> currentSets;
  final weightInputController = TextEditingController();
  final repsInputController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    currentSets = List.from([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add workout: ${widget.exerciseName}")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(children: buildSetWidgets()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      inputWithPlusMinus(
                        "Weight",
                        weightInputController,
                        (s) => double.parse(s),
                        (text) {
                          if (text != "" && double.tryParse(text!) == null) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                      ),
                      inputWithPlusMinus(
                        "Reps",
                        repsInputController,
                        (s) => int.parse(s),
                        (text) {
                          if (text == null) {
                            return "Enter a value";
                          }
                          if (int.tryParse(text) == null) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          currentSets.add((
                            double.parse(weightInputController.text),
                            int.parse(repsInputController.text),
                          ));
                        });
                      }
                    },
                    child: const Text("Add Set"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.post_add_rounded),
        onPressed: () {
          // capture context before async gap
          final localContext = context;
          showConfirmationDialog(localContext, "Save this workout?").then((
            confirmed,
          ) {
            if (confirmed ?? false) {
              _databaseService
                  .newWorkout(widget.exerciseName, currentSets)
                  .then((_) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(localContext);
                  });
            }
          });
        },
      ),
    );
  }

  Widget inputWithPlusMinus(
    String type,
    TextEditingController controller,
    Function parseFunction,
    FormFieldValidator validator,
  ) {
    final step = type == "Weight" ? 0.5 : 1;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(
                signed: false,
                decimal: type == "Weight",
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: type,
              ),
              validator: validator,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      final text =
                          controller.text.isEmpty ? "0" : controller.text;
                      var value = parseFunction(text) - step;
                      controller.text = value.toString();
                    },
                    child: const Icon(Icons.remove),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      final text =
                          controller.text.isEmpty ? "0" : controller.text;
                      var value = parseFunction(text) + step;
                      controller.text = value.toString();
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> buildSetWidgets() {
    List<Widget> setWidgets = List.from([]);
    int i = 1;
    for (var (weight, reps) in currentSets) {
      final currentI = i - 1;
      setWidgets.add(
        GestureDetector(
          child: SetWidget(n: i, weight: weight, reps: reps),
          onLongPress: () {
            setState(() {
              currentSets.removeAt(currentI);
              HapticFeedback.mediumImpact();
            });
          },
        ),
      );
      i++;
    }
    return setWidgets;
  }
}
