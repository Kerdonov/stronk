import 'package:flutter/material.dart';

class SetWidget extends StatelessWidget {
  final int n;
  final num weight;
  final int reps;

  const SetWidget({
    super.key,
    required this.n,
    required this.weight,
    required this.reps,
  });

  @override
  Widget build(BuildContext context) {
    final plural = reps == 1 ? "rep" : "reps";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text("$n."),
              ),
              Expanded(
                child: Text(
                  "$weight kg",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
              Text("$reps $plural"),
            ],
          ),
        ),
      ),
    );
  }
}
